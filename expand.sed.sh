#!/bin/sh
: Time-stamp: "Wed Oct 29 01:09:23 CEST 2007 olecom@flower.upol.cz"

t=`printf '\011'`
s=`printf '\040'`
s7=$s$s$s ; s7=$s7$s7$s

expand_sed_test='
	0	012	#
		01	#
	01	0	#
	012	012
	0123	012
	01234	0	#
	012345	01	#
	0123456	012	#
	0		0	1
			01	2
	01		012	3
	012		0123	4
	0123		01234	5
	01234		01234	5
	012345		0123456	7
	0123456		01234567
	t s t	  	0
01234          notab	0123
'
sed=$1 # 'echo' || 'cat -' can be supplied to see script or test case

# -Os (just basic funtionality, minimal size)
${sed:-sed} "
s-$t-$s7$t-g
s-\([^$t]\{8\}\)\($s\{0,6\}$t\)*-\1-g
s-$t-$s-g
" <<___
$expand_sed_test
___

exit

# -O2 (obvious speed improvement)
sed "
/$t/{
s-$t-$s7$t-g
s-\([^$t]\{8\}\)\($s\{0,6\}$t\)*-\1-g
s-$t-$s-g
}"
