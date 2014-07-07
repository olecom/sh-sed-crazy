#!/bin/sh
# vague task
# Time-stamp: Tue Apr 22 12:69:09 CEST 2008 olecom@flower.upol.cRAzY

change_file(){
# $1 -- 'a': change all but last $2
#       'l': change last $2 occurrences
# $2 -- number of last RE ; $3 -- REGEX ; $4 -- CHANGE

local E A B
E=`printf '\033'`
if [ "$1" = a ]
then A=$4   ; B='\1' ; echo "
change all '$3', but last '$2' to '$4'
"
else A='\1' ; B=$4   ; echo "
change last '$2' occurrances of '$3' to '$4'
"
fi >&2

printf %s "{
s $3 &$E g
h
s-[^$E]*--g
trange;:range
s-.\{$2\}.-&-
tre
s-.*-Error: 'n' is equal or greater than 'all'-
q
:re
# loop to change
s-\(.\{$2\}\).-\1-;trp
bend
:rp
x
s \($3\)$E $A ; # All
x
tre
:end
x
s \($3\)$E $B g # But n
q
}"
}

SCRIPT=`change_file "${1-a}" "${2-7}" "${3-RE..}" "${4-_CH_}"`

sed ':_nl;N;$'"$SCRIPT"';b_nl' <<''
line 1, RE11 RE12 RE13 RE14 RE15 RE16 RE17
line 2, RE21 RE22 RE23 RE24 RE25 RE26 RE27
line 3, RE31 RE32 RE33 RE34 RE35 RE36 RE37
line 4, RE41 RE42 RE43 RE44 RE45 RE46 RE47
line 5, RE51 RE52 RE53 RE54 RE55 RE56 RE57
