#!/bin/sh
# linux integrated development environment (without text editor/pager)

# Time-stamp: "Fri Apr 25 17:41:08 CEST 2008 olecom@flower.upol.cz"

[ "$lideRELOAD" ] || {
	[ -t 1 ] || exec dd count=1 # notty
	rm -rf /tmp/stderr.pipe /tmp/stdout.pipe
	mkfifo /tmp/stderr.pipe /tmp/stdout.pipe
# /tmp/stderr.txt is for `tee ` and off-line pager
}
set +i -e
stty -tostop

# own syntax:
# $E   is  'ESC[' = '\233'
# fork tty service
sed "s-[$]E-`printf '\233'`-g" << '# here' | /bin/sh -s &
set -e
# ${E} is   ESC   ; Ignored symbol for stderr prefix
E=`printf '\033'` ; I=`printf '\177'`

# wrap off for uncut stderr, or scrolling region can be used
printf '$E?7l'

# default fg;bg rendering ; reset attributes
D="7" ; RESET="$E0m"
# basic attributes (reset bg color and bold, set fg color)
V="$E40;22;3"

# wrap regex, multiple times per line
T=\''\"s-$1-$V$2m&$V${3-'$D'}m-$4;\"'\'
eval '
color_lide() {
# wrap regex with color
	# $1 -- regex ; $2 -- color code ; $3 -- next color code (default is $D)
	# $4 -- s///flags
	printf %s "`eval echo '"$T"'`"
}
scolor_lide() {
# color() with speed optimizing jump, thus, one regex in line
	printf %s "{`eval echo '"$T"'` ; b_$REGION}"
}
'
T=color_lide


## setup of regions

# main load:  stdout region, content is cut on width = $W

# small load: stderr, no cut; stderr out is rare, thus full lines

# parameters: all have content line limits (*LINES - 1)
#             *ORIGIN is a row placing (FIXME: add colons)

# console output concurrency: whole region is out with cursor move
#		 (no save/restore of it)

outLINES=10  ; outORIGIN=1 ; W=77
errLINES=14  ; errORIGIN=$(($outLINES + 5))
PMT="$E$(($outLINES + 3));1Hprompt:"

sed_GET_CHUNK=':addnl ; $!{ s $ '$EK' ; N ; baddnl }'

[ "$lideRELOAD" ] || {
	sed "# sed does final new lines here
$sed_GET_CHUNK
s ,-- $E$outORIGIN;1H& ;
s/ . -/$E30m&/g
s 0 1 ; s 0 2 ; s 0 3 ; s 0 4 ; s 0 5 ; s 0 6 ;

s-___-$E$errORIGIN;1H$E1;34;40m&$E31m-1
s-___-$E34m&$E31m-2
s/ _ /$E37m&$E31m/g
" << "---"
,-- kbuild: s - t - d - o - u - t --
|
|
`--
___ kbuild: s _ t _ d _ e _ r _ r ___
---
	printf "$PMT\n"
}

# shift title string

outORIGIN=$(($outORIGIN + 1))
errORIGIN=$(($errORIGIN + 1))


## handling of content

region(){
# buffered output with no more than LINES in continuously running `sed`
    # $1 -- type (out, stderr etc.) ; $2 -- region''s final line decoration
    eval 'printf %s "
# get prev. buffer; append current line
x ; G

# remove overflowed head (this sed''s something:)
$'"$1"'LINES,19810702s-^[^\\n]*\\n--

#$'"$1"'LINES,\$s-[^\\n]*\\n--
# last line  --^^ address yields debbug#475464: lost cycle

# save buffer; move to ${1}ORIGIN and print whole region
h ; s .* $E$'"$1"'ORIGIN;1H&\\n'"$2"' ;
"'
}

lideSYNTAX="
/[.,%/;:]/s [.,%/;:] $E1;36m&$E22;3${D}m g
/'/s-'\([^']*\)'-$E35m'$E36m\1$E35m'$E3${D}m-g"'
/"/s-"\([^"]*\)"-$E1;32;40m"$E22;39;44m\1$E1;32;40m"$E22;3'$D'm-g'"
/(/s-(\([^)]*\))-$E1;33m($E22;3${D}m\1$E1;33m)$E22;3${D}m-g
"
REGION=err
sed_STDERR="
$lideSYNTAX

# hard error
/^$I/s-.*-$E1;5;41;37m&${V}1;25;m$EK-
# ordinary
/^$I/!s-.*-&$EK-

# example of being friendly to kernel developers and kbuild users
/make /{s~make CONFIG_DEBUG_SECTION_MISMATCH=y~ksecmis~;b_$REGION}

# UPPER symbols:
`$T '[[:upper:]_]\{3,\}' '2' '1' g`
/[Ww][Aa][Rr]/`$T '[Ww][Aa][Rr][Nn][Ii][Nn][Gg]' '7;41;1' '1;40;22'`
/:/`$T '^[^:]*:' '2;1' $D`

:_$REGION
`region $REGION '$PMT'`
"

REGION=out
sed_OUT="
s-\(.\{0,$W\}\).*-|\1$EK-
/^|#/`s$T '#.*' '3'`
$lideSYNTAX
/:/`$T '^[^:]*:' '2;1' $D`
/ CC/`s$T CC  '6;1'`
/ LD/`s$T LD  '2;1'`
/ AS/`s$T AS  '5;1'`
/ GE/`s$T GEN '2;1'`
/ UP/`s$T UPD '2;1'`
/ CH/`s$T CHK '3;1'`
/ CA/`s$T CALL  '6'`
s-^-${V}${D}m-
:_$REGION
`region $REGION '\\\`--$PMT'`
"
unset lideSYNTAX

trap '
    printf "$RESET$E$(($errORIGIN + $errLINES))H"
    kill -1 $JJ ; kill -KILL $JJ
' EXIT HUP INT TERM QUIT

# close script's input, remove own stderr

exec 0<&- 2>/dev/null
tee -a /tmp/stderr.txt </tmp/stderr.pipe |
sed -u "$sed_STDERR" & JJ=$!' '$JJ
sed "$sed_OUT"    </tmp/stdout.pipe #>out.pipe & JJ=$!' '$JJ

exit

# stdout/stderr coloring daemon ends
# here

JJ=$! # save its pid
unset lideRELOAD
HISTLINE=:

lideCHECK_EXIT_STATUS='
S=$? ; Ex=Ex ; [ 0 -ne "$S" ] && Ex="\177"$Ex
sleep 1  # fix braindamage due to cuncurrency, buffers, other tty crap
printf  1>&2 "${Ex}it status: $S\n"'
trap "$lideCHECK_EXIT_STATUS"'"user interface is over\n"
	kill -1 $JJ

	rm -rf /tmp/stderr.pipe /tmp/stdout.pipe
	exit
' EXIT HUP QUIT

trap 'echo got SIGINT or SIGTERM 1>&2' INT TERM

exec 1>/tmp/stdout.pipe 2>/tmp/stderr.pipe

set +e

echo '# examples of being friendly to kernel developers and kbuild users:
commands: ksecmis ; kdefc ; (add yours) ; `make` crap ; any other
leave:    hell (`exit` is ignored)
'
lideBUILTINS="
ksecmis) LINE='make CONFIG_DEBUG_SECTION_MISMATCH=y' ;;
kdefc)   LINE='make defconfig' ;;
# add yours here
"

eval '

batch() {
case $1 in
'"$lideBUILTINS"'
*) LINE=\"\$@\" ;;
esac
eval "echo \"$LINE\" ; $LINE ; "'"$lideCHECK_EXIT_STATUS"'
exit
}

interactive() {
while read LINE
do echo "$LINE"
   case $LINE in
'"$lideBUILTINS"'
hell)    LINE=exit ;;
exit)    LINE=""   ;;

#reload) kill -1 $JJ ; export lideRELOAD=y ; exec /bin/sh $0 ;;
esac

eval "${LINE:-$HISTLINE} ; "'"$lideCHECK_EXIT_STATUS"'
[ "$LINE" ] && HISTLINE=$LINE
done
}
'
# `eval` must complete itself, no infinite loops inside
unset lideCHECK_EXIT_STATUS lideBUILTINS

[ -z "$1" ] && interactive || batch "$@"

sed 'sed && sh + olecom = love' << ''
-o--=O`C
 #oo'L O
<___=E M
