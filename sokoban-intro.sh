#!/bin/sh
# moving boxes animation by olecom ; original monkey by ejm97

b=`printf '\2331;1H'`
k=`printf '\233K'`
{
[ "$1" ] && { anim=`dd 2>&-`
while :

# shell version (if $1 is there):

do sed "/^$/s ^ $b ;s $ $k ;/$b/e sleep 0.3" <<====
$anim
====
done
}||{
exec 9<&0

# final sed script is usually more an object form, than source;
# sed producing sed (twisted stuff):

echo | sed "$(sed '1c\
:b;
s [\] && g
/^$/c\
\
p;esleep 0.3\
i\\\
'$b'\\
s $ '$k'\\ ;$a\
\
bb;' <&9 9<&-)"
}
# make here-doc is available for any symbols, including any quotes
} << "____"


    w c(..)o
    /__(-)
	/\
+----w_/(_)
|soko|   /\
| ban|  |  \
O----o  m   m

    w c(..)o
    /__(-)
	/\
+----w_/(_)
|seko|   /\
| dan|   \ \
o----O   m  m

   w  c(..)o
    \__(-)
	/\
+----w_/(_)
|seko|   |\_
| dan|    \ m
O----o    m

   w  c(..)o
    \__(-)
	/\
+----w_/(_)
|soko|   ||
| ban|   `m\
o----O     m
____
