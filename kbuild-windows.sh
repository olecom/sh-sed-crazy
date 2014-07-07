#!/bin/sh
# colorize linux build; coding: koi8-r

# Time-stamp: Wed Apr  9 13:78:13 CEST 2008 olecom@flower.upol.cRAzY

# for tty
#[ -t 1 ] || exec dd

color() {
# wrap regex with color
    # $1 -- regex
    # $2 -- color code
    # $3 -- next color code (default is $D)
    # $4 -- regex match number (s///flags)
    # $5 -- label name (speed optimizing goto; defaul is the end)
    printf %s "`eval echo $OUT`"
}

# escape symbol ; Ignored symbol for stderr prefix
E=`printf '\033'` ; I=`printf '\177'`
# default fg;bg rendering ; reset attributes
D="7" ; RESET="$E[0m"
# basic attributes (reset bg color and bold, set fg color)
V="$E[40;22;3"
T=color
OUT='"{s-$1-$V$2m&$V${3-'$D'}m-$4 ; b_$JMP}"'

sed_GET_CHUNK=':addnl ; \$!{ s $ '$E[K' ; N ; b_addnl }'

# below stdout must be stderr window (for uncut info)
# output is rare, thus big number of lines to redraw

errLINES=15
JMP=stderr
sed_STDERR=$sed_STDERR"
$sed_GET_CHUNK

/WA/`$T WARNING '7;41;1' '1;1;40'`
s-^-${V}1;1m-
:_stderr
"

# stdout window, 2 lines, no wrapping
JMP=stdout

outLINES=2
W=77
sed_STDOUT=$sed_STDOUT"
/^$I/b
s-^-|-
s-\(.\{1,$W\}\).*-\1$E[K-
/ CC/`$T CC  '6;1'`
/ LD/`$T LD  '2;1'`
/ AS/`$T AS  '5;1'`
/ GE/`$T GEN '2;1'`
/ UP/`$T UPD '2;1'`
/ CH/`$T CHK '3;1'`
/ CA/`$T CALL  '6'`
s-^-${V}2m-
:_stdout
x ; G

$outLINES,\$s-[^\n]*\n--
h ; s'$'$E[1;1H'
"

# sed does final new lines here
sed "
$sed_GET_CHUNK

s/ . -/$E[30m&/g
s 0 1 ; s 0 2 ; s 0 3 ; s 0 4 ; s 0 5 ; s 0 6 ;

s-___-$E[1;34m&$E[31m-g
s/ _ /$E[37m&$E[31m/g
s-^-$E[1;1H$E[1;40m-
" << "---"
,-- kbuild: s - t - d - o - u - t --
|
|
`--

___ kbuild: s _ t _ d _ e _ r _ r ___
---

while dd=$dd`dd count=1 2>/dev/null`
   do sed "$sed_STDERR" << ]
"$I$E[7;1H$dd$E[1;1H"
]
done <stderr.pipe>stdout.pipe & JJ=$JJ$!

trap 'kill -1 $JJ' EXIT HUP INT TERM QUIT

sed "$sed_STDOUT" <stdout.pipe & JJ=$JJ$!

"$@" >stdout.pipe 2>stderr.pipe

printf "$RESET







"
  exit
