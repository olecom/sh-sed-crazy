#!/bin/sh
#  by olecom (Oleg Verych)
## Time-stamp: <Mon Jul 30 20:55:41 CEST 2007 olecom@deen.upol.cz.local>

## The main idea is that after removing literals, all strings' content
## is inside double quotes, everything else is outside.

# Imlementation without C++ crap: real     0m19.469s

# remccom3.sed is OK, but slow; the fresh run timings (in this order):
#olecom@deen:/tmp/__$ time sh ../strip-c.sh test
#
#real    0m24.061s
#user    0m21.629s
#sys     0m2.424s

#   du -s: 42284  ../MPlayer-1.0rc1/
#original: 49060

#olecom@deen:/tmp/__$ time sh -c 'for i in `find . -name "*.[ch]"`; do ../remccoms3.sed "$i"  >  "../MPlayer-1.0rc1/$i" ; done'
#
#real    0m47.598s
#user    0m45.199s
#sys     0m2.400s
#olecom@deen:/tmp/__$
#olecom@deen:/tmp/__$ time sh -c 'for i in `find . -name "*.[ch]"`; do sed -f ../remccoms[12]* <"$i" > "../MPlayer-1.0rc1/$i" ; done'
# Implementation is too naive, it breaks sources
# 1: real    0m4.787s
# 2: real    0m20.644s

sc_setup() {
#
    sc_consts() {
	q=$1 # replacement for a quote in _\"_,_'"'_ literals
	c=$2 # comment start symbol: /*
	e=$3 # end: */
	p=$4 # polymorph: /*/
	m=$5 # marker
	P=$6 # //, //*, //*/ (oh crap)
	a=$7 # marker for C++
    }
    sc_consts `printf '\007 \006 \005 \004 \003 \002 \001'`

    CSED='
#/\/\/STOP/{s_^_/* stop due to debug */_p;q;}
## line start
##
/^[[:blank:]]/{
# speed up
	# rm whitespace
	s_^[[:blank:]]*__;
}
/^$/d;
/^\/\//d;

:_line;
## rest of the line
## NOTE: this block is reentrant to handle appended line in multiline
##	 C comments; thus branching must be taken with care
/\\[[:blank:]]*$/{
# lines with Trailing Backslash are joined
	s_[[:blank:]]*\\[[:blank:]]*$_ _;
	N;
	s_\n[[:blank:]]*__;b_line;
}

# reset state due to not using "t" above
t_r;:_r;

##(speed up) end if not C comment start
/\/\*/!{
#slowdown: real    0m20.976s
	/"/{
		s_//_'$P'_g;t_cpp;
		# restore contents in the strings
		b_end
	}
	# speed up
	s_//.*__;
	s_'$m'__;
	# small slowdown: a little bit of whitespace shooting
	s_ *\([=,]\) *_\1_g;
	s_[[:blank:]]\{2,\}_ _g;
	p;b;
};
## otherwise
s_/\*_'$c'_g;t_c;:_c;
/\*\//!{
	# just multiline C comment
	s_^'$c'.*__;t_nmc;b_begin;
	:_nmc;
	N;
	# prepare ending symbols
	s_\*/_'$e'_;t_emc;b_nmc;
	:_emc;
	s_.*'$e'[[:blank:]]*_ _
	/^ $/d;
	# rescan the line after N command
	t_line;
};
:_begin;
## inline C comments
# speedup: full comment string (real 0m24.914s)
/^'$c'[^'$c']*$/{/\*\/$/d};

# setup or leave the marker
/'$m'/!s_^_'$m'_;

# convert literals
s_\([\'"'"']\)"_\1'$q'_g;

# convert symbols
s_'$c'_/*_g;
s_//_'$P'_g;
s_/\*/_'$p'_g;
s_/\*_'$c'_g;
s_\*/_'$e'_g;

/"/!{
# speed up: no strings
	## skip string processing (+ TODO below)
	# kill some whitespace
	s_[[:blank:]]\{2,\}_ _g;
	b_tail;
};

## now any C string have only one couple of double quotes;
## in the C comments there are can be any number of double quotes

# reset (get ready)
t_nextbs;
:_nextbs;
# rm comments before first string
s_'$m'\([^"'$c$p']*\)['$c$p'][^'$e$p']*['$e$p'] *_\1 '$m'_;t_nextbs;

# move marker behind string in case, if there is one left
s_'$m'\([^"'$c$p']*"[^"]*"\)_\1'$m'_;t_nextsc;b_nextc;
# start of iteraction(s), rm comments after "strings" one by one using marker
:_nextsc;

# rm comments (if any) between strings
s_'$m' *\([^"'$c$p']*\)['$c$p'][^'$e$p']*['$e$p'] *\([^"'$c$p']*\)_\1 \2'$m'_;

t_nextsc;
# move behind the next string (if any)
s_ *'$m' *\([^"'$c$p']*"[^"]*"\)_\1'$m'_;
t_nextsc;

:_tail;
t_nextc;
:_nextc;
# rm comments in the end (if any)
s_'$m'\([^'$c$p']*\)['$c$p'][^'$e$p']*['$e$p']\([^'$c$p']*\)_\1 \2'$m'_;
t_nextc;

# C++ crap
/'$P'/{
	/"/!{
		# no string -- 100% chance
		:_rm;
		s_'$P'.*__;t_ckml;
		:_ckml;
		/^$/d;
		/'$m'/b_mlc;
		b_end;
	};
	:_cpp;
	# rm if string is behind $P
	s_^\([^"'$P']*\)'$P'.*_\1_;t_end;
	# move behind first string
	s_\("[^"]*"[^"'$P']*\)_\1'$a'_;t_gon;b_rm;
	:_gon;
	# try to remove C++ comment
	s_'$a$P'.*__;t_ckml;
	s_'$a'\([^"]*"[^"]*"[^"'$P']*\)_\1'$a'_;t_gon;
	s_'$a'__;t_ckml;
#final:	   real    0m21.006s
#last fix: real    0m23.807s
};
:_mlc;
# check for the multiline comment in the end: start it with $m
s_'$m'\([^'$c$p']*\)['$c$p'].*_\1'$m'_;t_nextmc;b_end;
# find the end and rm it all
:_nextmc;
N;
# prepare ending symbols
s_\*/_'$e'_;t_esymb;b_nextmc;
:_esymb;
s_'$m'.*'$e'_'$m' _;t_left;b_nextmc;
# appended string (after N) requires full cycle, in case if something left
# TODO: try to optimize with P (partial printing) lines without strings,
#	dubt it will be	very fast, but surely script will be bigger
:_left;
/^'$m' $/d;
b_line;
:_end
s_'$m'__;
s_[[:blank:]]*$__;
# NOTE: this test is faster(why?):
/['$P$c$e$p']/{
# slower, but shorter: /"/{
	s_'$P'_//_g;
	s_'$c'_/*_g;
	s_'$e'_*/_g;
	s_'$p'_/*/_g;
};
s_'$q'_"_g;
p'

sc_strip() {
    sed '
/^[[:blank:]]*#/d;
/^[[:blank:]]*$/d;
s_^[[:blank:]]*__;
s_;$__;' <<__
$1
__
}

CSED=`sc_strip "$CSED"`
}

sc_setup
unset sc_strip sc_consts sc_setup

test test = "$1" && sed -i -n "$CSED" `find . -name "*.[ch]"` || sed -n "$CSED"
#real    0m20.720s
