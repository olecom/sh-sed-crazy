#!/bin/sh -e
#
# Time-stamp: <Tue Jun  5 04:15:47 CEST 2007 olecom@flower.upol.cz>

# This is a rewrite of the `checklibs' by
# Author: Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com )

# find all undefined symbols in the files (it's `pwd` now)
# find all linked libraries (ELF's NEEDED)
 # search libs in std and extra paths
   # for each found one: ok look at its symbols and compare with what we have,
     # if found any symbols then: ok, next
     # else: Bark! Library is linked, but *no* symbols are used, print files
   # else: next

# this must be more logic/speed optimized version, however searching
# symbols by the shell may have a speed bottleneck
# update: tested - acceptable from 2 up-to `/usr/bin/*' files

# Wish list:
# 1) compare SONAME and file-system name (anything else, actually :)
# 2) symbol versions (value of symbol name variable already has
#    version e.g. `@GLIBC_2.2.5 (2)', but it is the first (don't know
#    if DSO can have many same symbol names with different versions)

# using `elfutils' for better output and clear syntax of symbol versions

case "$1" in
-l | --li?ense) echo "
Public domain. Courtesy of the Debian.
"; exit;;
esac

set -e

export LANG=C
APPNAME="${0##*/}"
TOOLSET=elfutils
STDERR= #">/tmp/chl_stderr.log" # for so-called debug, stderr is handy
[ -n "$STDERR" ] && eval "set -x; exec 2>$STDERR"

info(){
    echo $APPNAME: $* 1>&2
}

hash eu-readelf

CHLPATH=/lib:/usr/lib:$EXTRA_LIBRARY_PATHS:
CHLPATH=`echo $CHLPATH | sed -e 's_/*:_:_g;s_:_ _g;s_[ /]*$__'`
# bad path test case: `echo /lib//:::/usr/lib///:/jj/kk/`

chl_elfutils_syms_needlibs() {
# $1 - `bin' or `lib' mode (see actions below)
# $* - files to check, `readelf' may fail on non ELF -- it's its job

# looking (after first "Dyn..") for linked libraries ("c" is a regex clue):

# NOTE: `[-.+]' are removed from lib __shell variable name__:
#	"CHLLlibglib-2++" -> "CHLLlibglib2"
# more incompatible symbols shoulf be added, if needed

#|flower:-$ eu-readelf -ds -- /bin/dash | grep NEED
#| NEEDED            Shared library: [libc.so.6]
#c^      ^ "not ["                    ^not"." ^ not "]"
#| VERNEED           0x00000000004011a8
#
# (after and up-to empty line) look for undefined symbols:
#|  Num:
#c ^^^
#|  0: 0..0  0 NOTYPE  LOCAL  DEFAULT  UNDEF !this all is removed
#...
#| 93: 0..0 16 FUNC    GLOBAL DEFAULT  UNDEF __strtoll_internal@GLIBC_2.2.5 (2)
#| 94: 0..)  0 NOTYPE  WEAK   DEFAULT  UNDEF __gmon_start__
#c                                          ^ not [ @]         ^[@]*, not [@]
#`-*-
# for defined symbols _spaceless_ string from the end is being got
# output is `ACTION?'
    local status UNDEFINED DEFINED ACTION1 ACTION2

    if [ "$1" = bin ]
    then
	# \1 - needed library name
	# \2 - suffix,  e.g. `.so.6'
	# collect unique lib names with refs
	ACTION1='[ -z "$CHLL\1" ] \&\& CHLIBS="$CHLIBS \2";CHLL\1=$CHLL\1"$F "'

	# undefined symbols
	# \1 - symbol name
	# \2 - version, e.g. `@GLIBC_2.2.5 (2)'
	# symbol refs; this is parsed by the shell and yields unique variables
	ACTION2='CHLS\1="@\2"'
	UNDEFINED='
/  Num/,/^$/{
s_ Num:__;t;
s_.* UNDEF *__;T; # find + clean or next
s_^ *$__;t;
s_\([^@]*\)@*\([^@]*\)$_'"$ACTION2"'_;
p};'
    else
	[ -n "$STDERR" ] && echo 'set -x; exec 2>'$STDERR

	# `0' here to avoid symbol name collisions
	# needed libraries for a library
	ACTION1='CHL0L="$CHL0L \2"'
	# make refs, collect symbols form a lib;
	ACTION2='S0\1="@\2";S=$S" \1"'

	# defined symbols
	DEFINED='
/^  Num/,/^$/{
s_ Num:__;t;
s_ UNDEF __;t;
s_ LOCAL __;t; # find not or next
#s_^[ ]*$__;t;
s_\([^ ]*\)$_|\1_; # last word is marked with |
s_[^|]*|__; # all from start to | inclusive removed
s_\._p_g # handle name error like "GLIBC_2.3@@GLIBC_2.3"
s_\([^@]*\)@*\(.*\)_'"$ACTION2"'_;
p};'
    fi
    shift

    # re-parsing was good back in 90s with perl, so don't multiply same code
    # thus, it will parsed by `eval' and proceeded further

    # magic for saving exit status of the helpers
    exec 4>&1 # stdout is to be pipe via fd 4, fd 5 is for status via stdout

    status=`{ (eu-readelf -ds -- $* 4>&- 5>&-; echo $? 1>&5) | /bin/sed -n -e '
/\/.*:$/{s_^\(.*\):$_F="\1"_;p} # filename
/^Dyn/,/^$/{
s_ NEEDED [^[]*__;T; # find + clean, or next
s_\[\([^.]*\)\([^]]*\)]_\1\2_;h;
s_[-.+\n]__g;G; # compatible shell name
s_ \(.*\)\n \(.*\)_'"$ACTION1"'_;
p;d};'"$UNDEFINED$DEFINED"; } 5>&1 1>&4`

    exec 4>&-
    # record status, `eu-readelf' returns 1 if some files were not ELF
    echo "[ $?$status -le 1 ] && :"

    [ -z "$DEFINED" ] && return

    # compare S(lib symbols) against CHLS(bin)
    # 1) only one catch
    # 2) complete search with version checking
    #
    # second eval, exit status `0' -- symbol exists
    echo '
set -- $S
while [ -n "$1" ]
do if eval [ -n \"\$CHLS$1\" ]
   then exit 0;
   fi
   shift
done
exit 1
'
}

unset CHLIBS # to be filled

info "scanning..."

eval "`chl_${TOOLSET:=elfutils}_syms_needlibs bin ./\*`"

set -- $CHLIBS # make found libraries as parameters for easy access

while [ -n "$1" ]
do for p in $CHLPATH
   do [ -e "$p/$1" ] && { if (eval "`chl_${TOOLSET}_syms_needlibs lib $p/$1`")
      then : #echo "$p/$1 - OK";
      else
	  printf %b "[$p/$1]\t\t? ["
	  eval printf '%b]\\n' \"\$CHLL`eval echo $1 | sed -e 's_[-.+\n]__g'`\"
      fi; break; }
   done
   shift
done
info "... done."

# shend
