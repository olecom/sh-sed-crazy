#!/bin/sh
# colorize linux build; coding: koi8-r

# Time-stamp: Wed Apr  9 13:78:13 CEST 2008 olecom@flower.upol.cRAzY

color() {
    # $1 -- regex
    # $2 -- color code
    # $3 -- next color code (default is $D)
    # $4 -- regex match number
    printf %s "`eval echo $TERMINAL_OUTPUT`"
}

# for tty
[ -t 1 ] && {
    # escape symbol
    E=`printf '\033'`
    # default fg && bg rendering ; reset attributes
    D="7" ; RESET="$E[0m"
    # basic attributes (reset bg color and bold, set fg color)
    V="$E[40;22;3"
    # wrap regex with color ; goto exit
    TERMINAL_OUTPUT='{s-"$1"-"$V$2m&$V${3-'$D'}m"-$4 ";" b}'
}

# process stdout

[ -z "$COLORIZERR" ] && {
    sed "
/CC/` color CC '6;1'`
/LD/` color LD '2;1'`
/AS/` color AS '5;1'`
/GEN/`color GEN '2;1'`
/UPD/`color UPD '2;1'`
/CHK/`color CHK '3;1'`
/CA/` color CALL '6'`
s-^-${V}2m-
"
    printf "$RESET
"
    exit
}

# process stderr (once)

while read ERROR
do OUT=$OUT'
'$ERROR
done

printf "\033[1;37;41m$OUT$RESET
"
exit

# usage

olecom@flower:/tmp/blinux$ stty -tostop
olecom@flower:/tmp/blinux$ mkfifo /tmp/colorize-out.pipe /tmp/colorize-err.pipe
olecom@flower:/tmp/blinux$ sh /tmp/colorize.sh </tmp/colorize-out.pipe &
[1] 28138
olecom@flower:/tmp/blinux$ COLORIZERR=yes sh /tmp/colorize.sh </tmp/colorize-err.pipe &
[2] 28145
olecom@flower:/tmp/blinux$
olecom@flower:/tmp/blinux$ make >/tmp/colorize-out.pipe 2>/tmp/colorize-err.pipe
make -C /mnt/zdev0/linux-2.6 O=/dev/shm/blinux/.
  Using /mnt/zdev0/linux-2.6 as source for kernel
  GEN     /dev/shm/blinux/Makefile
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  CALL    /mnt/zdev0/linux-2.6/scripts/checksyscalls.sh
  CHK     include/linux/compile.h
  CC      arch/x86/mm/init_64.o
  CC      arch/x86/mm/fault.o
  CC      arch/x86/mm/ioremap.o

olecom@flower:/tmp/blinux$
make[3]: *** wait: No child processes.  Останов.
make[3]: *** Ожидание завершения заданий...
make[3]: *** wait: No child processes.  Останов.
make[2]: *** [arch/x86/mm] Ошибка 2
make[1]: *** [sub-make] Interrupt
make: *** [all] Interrupt

[1]-  Done                    sh /tmp/colorize.sh </tmp/colorize-out.pipe
[2]+  Done                    COLORIZERR=yes sh /tmp/colorize.sh </tmp/colorize-err.pipe
olecom@flower:/tmp/blinux$

# end
