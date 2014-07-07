#!/bin/sh

# break long lines, like after `pdftotext`

W=${1:-79}
t='  '
t=$t$t$t$t
S=`printf '\001'`

sed "
# some C formating
s-{ *-{\n-g
s-} *-\n}\n-g
s-; *-;\n-g" | sed -n "
:_n

/{$/{
# indent C blocks
:_op
	/{\n*$/{x;s-$S*-$S$t-;x}
	P;n
	/^$/b_op
	/};*$/{x;s|^$S$t$|$S|;x;t_n;x;s-$t$t-$t-;x}
	G
	s-^\([^$S]*\)$S\(.*\)-\2\1-
	t_op
}

s-^\(.\{$W\}\)\(.\)-\1$S\2-;t_long
# '-n' is used
p
## add explicit exit condition (slash for double quotes in shell)
\$q
## added implicit 'n' and fixed jump to the start for easy script reuse, was:
##>b
n
b_n
##
:_long
/^[^ ]*$S/ {
# break long line-word by a backslash
	s-\(.\)$S-\\\\\n$S\1-
	P
	s-^[^$S]*.--
	t_n
}
/$S / {
:_else
# whole word in the end
	s-$S-\n&-
	P
	s-^.*$S *--
	/^$/b
	t_n
}
# pick last word together
s-\( *\)\([^ ]*\)$S-\n$S\2-;t_s
b_else
:_s
# cut line is ready
P
# do the rest
s-^[^$S]*.--;t_n"
