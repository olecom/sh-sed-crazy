#!/bin/sh -e
# clean whitespace damage; i/o = $1/$1.clean

IFS='' ; t="`printf '\t'`" ; s=' ' ; s4="$s$s$s$s" ; w79=79 ;
i="$1" ; o="$1.clean"
strip_file_end='/^$/{N;s_^\n$_&_;T e;:n;N;s_^.*\n\n$_&_;t n;:e;};'
not_patch_line='/^+[^+]/'

case $1 in *[.]diff | *[.]patch)
	file=patch ; sp='+[!+]' ; p='+' ; addr="$not_patch_line";;
esac

sed -n "${addr:-$strip_file_end} {
s|[$t$s]*$||;	# trailing whitespace
:next;		# x*8 spaces on the line start -> x*tabs
s|^\([\n]*\)$p\($t*\)$s4$s4|\1$p\2$t|;t next;	# \n is needed after N command
s|^\([\n]*\)$p\($t*\)$s*$t|\1$p\2$t|g;		# strip spaces between tabs
s|$s4$s4$s$s*|$t$t|g				# more than 8 spaces -> 2 tabs
s|$s*$t|$t|g	# strip spaces before tab; tradeoff: may break some alignment !
};p" -- "$i" >"$o" && echo "
please, see clean ${file:=source} file: $o
"
exec expand $i | while read -r line # check for long line
do   [ ${#line} -gt $w79 ] && case "$line" in $sp*) echo \
"at least one line wider than $w79 chars, found
check your $file, please
" 1>&2 ; exit ;; esac
done
