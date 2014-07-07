#!/bin/sh -e
: Time-stamp: "Mon Sep 10 04:11:59 CEST 2007 olecom@deen.upol.cz.local"
: Text User Interface in MPlayer Sucks

# tab(skip back) w(play next entry) e(skip forward); skip = 1 minute
# a(volume down) s(play prev entry) d(volume up);

# idea: fork `mplayer fifo1 fifo2 <fifo3` (backend), play blocks on the
# first so called file, until media stream writer is available;

# then in (control) loop writer becomes available in form of
# `dd <if>fifo1` ; when stream ends, backend opens second one. Control
# sees this, switches loaded file forward (backward, see below), sends
# "back" command to backend via fifo3, thus closes the loop.

# !! if "$1" isn't a file, try to play it as "./{`*', `*/*', `*/*/*' }"
# !! playlist file: first line is a directory to `cd`
# ** shell patterns in name are expanded;
#    e.g. to play list of directories: add `/*' after each
# ** to play directory structure (3 levels max), leave just first line

# - bash have $$ inside ( ) &, that equals to foring shell, not forked
# - bash executes functions inside trap, dash does not
# - ?bash don't care about `set -e` inside `trap`
# - 2>/dev/null redirection also kills `set -x` output in dash
# - dash does not allow (support?) opening redirections to high fds (e.g. 77)

set -e

backend="${2:-mu-mplayer}"
p=""		# PIDs of childs: player backend, etc.
a="/tmp/ma$$"	# first argument of backend
b="/tmp/mb$$"	# second
c="/tmp/mc$$"	# stdin (control) of it
d="/tmp/md$$"	# delta or currently played #entry
l="$1"		# playing stuff
tty=`tty`
[ -p "$a" -a -p "$b"  -a -p "$c" ] || {
    rm -rf "$a" "$b" "$c" ; mkfifo "$a" "$b" "$c"
}
[ -r "${l:=.}" ] || { echo "Can't read \`$l'." ; exit 1 ; }

# running backend
echo "
Starting backend (default or use \$2 to change it)..."
hash "$backend"
"$backend" "$a" "$b" <"$c">/dev/null &
p=$!
echo "Backend \`$backend' started \`pid=$p'
"
echo "0">"$d" # start #id-1
exec 2>/dev/null

p="$p $$"
(    # Backend serviving;
trap  '\
set +e ; stty --file $tty icanon echo ; rm -f "$a" "$b" "$c" "$d"
echo "
Backend service exiting$RR...
">$tty ; kill '"$p" EXIT

IFS=`printf '\n\t'`
{ read A && cd "$A" && {
  read A
  test "$A" && set -- $A `dd` || set -- * */* */*/*
  }
} <"$l" || set -- "$l"/* "$l"/*/* "$l"/*/*/* "$l"/*/*/*/*

echo "Play list has $# entries."

while  :
do  read  P <"$d"  ;  P=$(($P + 1))
    test $P -ge 0 -a $P -le $#   || { RR=" (play list is empty)" ; exit 1 ; }
    test $P -le 0 &&  P=1 ; echo "$P">"$d"
    F=\${$P\} ; F="`eval echo \"$F\"`"

    if   test "!" -d "$F" -a -r "$F"
    then echo "Playing #$P: ${F##*/}..." ; dd bs=$((1 << 20)) <"$F">"$a" || :
    else echo "Fail to load ${F##*/}" ; continue
    fi

    exec  4>"$c" 5>"$b"	# block, until "$b" is accesed;
    echo  -n  "<">&4	# POSIX, why didn't you awarded shell
    exec  4>&-   5>&-	# with select(2)?

done <&2  ) &
p="${p% *} $!"

trap  "echo 'Got interrupt signal'	 >$tty" INT
trap  "echo 'No response from backend'	>$tty" PIPE
trap  '\
set +e ; stty --file $tty icanon echo ; rm -f "$a" "$b" "$c" "$d" ; kill '"$p"'
echo "
Exiting...
" >$tty' EXIT

E=`printf '\033'`
T=`printf '\011'`
U=$E[A ; D=$E[B

stty -icanon -echo
while :
do  i=`dd count=1`
    # handling of mplayer specific input plus some of our mappings
    case $i in
	"<"*|s*) read  i <"$d" ; echo "$i-2" >"$d"   # race to death with
		 echo -n '>' ; sleep 1 ; continue ;; # automatic stream change,
	">"*|w*) echo -n '>' ; sleep 1 ; continue ;; # input rate limit
	$T)i=$D ;;
	e) i=$U ;;
	l)	;; # will be new list loading and all that fancy TUI
	d) i=0	;;
	a) i=9	;;
	g|j) {
		echo -n "#id: "
		stty icanon echo ; read i ; stty -icanon -echo
	     }  >/dev/tty
	     [ "$(($i))" != 0 ] && {
		echo "$i-1" >"$d"
		echo -n ">"
	     }
	     continue ;;
	q) echo q >"$c" ; exit 0 ;;
    esac
    echo -n "$i"
done >"$c" # actually starting backend, btw

# shend
