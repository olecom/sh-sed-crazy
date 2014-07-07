#!/bin/busybox sh

# bad `t' command. Fixed as in busybox 1.6.0
ACTION2='CHLS\1="@\2"'
eu-readelf -ds * | grep UNDEF | sed -n -e '
s_.* UNDEF *__; # find + clean or next
s|^ *$|%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5|;t
p;};'

exit
# result:
# only \n is defibed in the POSIX, thus busibox is lazy to handle \t
ACTION2='S0\1="@\2";S=$S" \1"'
 '
/^  Num/,/^$/{
s_[\t ]Num:__;t;
s_[\t ]UNDEF[\t ]__;t;
s_[\t ]LOCAL[\t ]__;t; # find not or next
##s_^[\t ]*$__;t;
s_\([^\t ]*\)$_\1_; # last word is marked with |
#s_[^|]*|__; # all from start to | inclusive removed
#s_\._p_g # handle name error like "GLIBC_2.3@@GLIBC_2.3"
#s_\([^@]*\)@*\(.*\)_'"$ACTION2"'_;
p};'
