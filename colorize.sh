#!/bin/sh
# Time-stamp: "Tue Apr  8 03:10:50 CEST 2008 olecom@flower.upol.cRAzY"

color() {
    # $1 -- regex
    # $2 -- color code
    # $3 -- next color code
    printf %s "`eval echo $TERMINAL_OUTPUT`"
}

# for tty
[ -t 1 ] && {
  # escape symbol
  E=`printf '\x1B'`
  # default rendering
  D="$E[0m"
  # attributes for filtered stuff (reset bg color and bold, set fg color)
  V="$E[40;22;3"
  TERMINAL_OUTPUT='s-"$1"-"$V$2m&$V${3-0}m"-;'
}

exec sed "
`color '[^:]*' 4 3`
`color :       3 2`
`color AMD     6 2`
`color Intel   6 2`
`color Athlon  '6;44' 2`
`color Pentium '6;44' 2`
"
