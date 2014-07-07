#!/bin/sh -e
: Time-stamp: "Wed Sep 12 00:03:02 CEST 2007 olecom@deen.upol.cz.local"

set -e

E=`printf '\033'`
N=`printf '\177'`
t=`printf '\011'`
SC="$E"7
RC="$E"8

c=0
O=40
Debian=""
c=31  #colour

IFS=""
while read l ; do Debian="$l$N$Debian" ; done <<"__EOF__"
	_=coLINUXol=_.
      .S@P"'      `TSe.
    .wdP'           `"YQ.
   .mX'     _xaXax_   `Xb.
  dZ['    jDY'~  ?Ja   YL)
 j#e'    fEP      `X)  `E)
 XG:    (B(        x)  ;N'
 S#;    `IK;     ,sP  ,ND'
 `WD.    ?Ac.   '    ,Y7
  YSb     `Nbc.__,ujJb'
   Y#b,    `"=?@YPDT'
    `Xgc.
      `P@Le,
	`tGgc,_
	  `"SUPer__
	      `~~~~'
__EOF__

Visual=`echo -n "$E[40m$E[17;${O}H$Debian" | sed "
s-$N-$E[${O}G$E[1A-g;
s-\([^ $t]\{1,\}\)-$N\1$N-g;
s-$t-$E[8C-g;
s- \{5\}-$E[5C-g;
s- \{2\}-$E[2C-g;
s- \{1\}-$E[1C-g;
"`

first_act=" 2  3  4  5  6  7  9  11 15 19 23 27 31 34 36 38"
second_act="37 35 33 30 26 22 18 14"
third_act=" 10 12 16 20 24 28 32"
act_fourth="29 25 21 17 13"
pause=0.15
IFS=" "

while Movie="$Visual"
do for   i in $first_act $second_act $third_act $act_fourth
do case $i in # NOTE: very image specific stuff
   38)  Movie=`echo -n "$Movie" | sed "s-$N[^$N]*$N-$N&-38"`
	for i in "." "" "" "."
	do Movie=`echo -n "$Movie" | sed "
s-$N$N\(...$i\)-$E[1;${c}m\1$E[30m$N$N-"`
	echo -n "$Movie"
	sleep "$pause"
	done
	continue ;;
   10)
	i="jJb' _,u c[.]_ " ; j="T' YPD =?@ "
	while [ "$i" ]
	do Movie=`echo -n "$Movie" | sed "
s-${i%% *}-$E[1;${c}m&-;
s-${j%% *}-$E[1;${c}m&-;"`
	echo -n "$Movie"
	i=${i#* } ; j=${j#* }
	sleep "$pause"
	done
	i='`Nb' ; s="$E[1;${c}m"'`'"$E[37mN$E[${c}mb" ; j='`"'
	Movie=`echo -n "$Movie" | sed "
s-$i-$s-;
s-$j$E-$E[1;${c}m&-;"`
	echo -n "$Movie"
	sleep "$pause"
	continue ;;
30|26|22|18|14 | 12|16|20|24|28)
	Movie=`echo -n "$Movie" | sed "
s-$N[^$N]*$N-$E[1;${c}m$N&$E[30m-$i
s-$N\($N.\)\([LENYAIBD]\)-$E[1;${c}m\1$E[37m\2$E[${c}m-"`
	echo -n "$Movie"
	sleep "$pause"
	continue ;;
   esac
   Movie=`echo -n "$Movie" | sed "
s-$N[^$N]*$N-$E[1;${c}m&$E[30m-$i"`
   echo -n "$Movie"
   sleep "$pause"
done
sleep 0.5
echo -n "$Movie" | sed "
s-_=co.*[.]-$E[0;31m_=coLINUXol=_.-"
sleep 0.3
echo -n "$Movie" | sed "
s-_=co.*[.]-$E[0;30m_=coLINUXol=_.-"
sleep 0.7
echo -n "$Movie" | sed "
s-_=co.*[.]-$E[1;37m_=$E[33mco$E[32mL$E[31mI$E[34mN$E[35mU$E[36mX$E[33mol$E[37m=_.$E[0m-"
sleep 3
done
exit
