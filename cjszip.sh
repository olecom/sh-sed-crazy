#!/bin/sh
## Time-stamp: <Tue Nov  8 21:45:07 EET 2005>
## Author: <olecom@is.from.by>
## Note. This file is in public domain.

1. Public doman does not violate (L)GPL.
2. Even if (L)GPL violated, public domain just doesn't care.
   (Conversely this doesn't applicable ;-)
3. No warranty of any kind: usability or even working, etc.
4. Finally. If it doesn't work at all, just drop it down.

##
# C and javaScript src compressor

c_js_compressor()
{
    sed -r ';s_\r__g;s_(/\*)_\\\n\1\n_g' $1  |\
    sed -r '/\/\*/,/\*\//{s_(\*/)_\n\1\n_;}' |\
    sed -r '/\/\*/,/\*\//d' |\
    sed -r '/\\[ \t]*$/ {:more;N;s_\\[ \t]*\n__g;t more;};/\\[ \t]*$/bmore;' |\
    sed -r '/^\/\//d;s/([^\\])\/\/[^\/].*$/\1/;s_^[ \t]*__' |\
    sed -r '/".*[^"][ \t]*$/s_("[^"]*")_\\\n\1\\\n_g;/.*"[ \t]*$/s_("[^"]*")_\\\n\1\n_g' |\
    sed -r '/^[^"]+$/{s_[ \t]*([]#<>~![+=*/?|&:;,}-])[ \t]*_\1_g;}
/^#/{s_[ \t]+([({])[ \t]*_ \1_g;s_([)])[ \t]+_\1 _g;s_([{(])[ \t]+_\1_g;s_[ \t]+([)])_\1_g;}
/^[^#]/{s_[ \t]*([(){]+)[ \t]*_\1_g;}' |\
    sed -r '/^[\t ]*$/d' |\
    sed -r '/\\$/ {:more;N;s_\\[ \t]*\n__g;t more;};/\\[ \t]*$/bmore;' |\
    sed -r -n ':join;/^[ \t]*#/{p;n;};s_([^};])\n_\1 _;$p;N;/[\n]?#/{p;n};
s_[ \t]*([{};])[ \t]*\n[ \t]*_\1_g;s_[ \t]*([0-9a-zA-Z_*])[ \t]*\n_\1 _g;bjoin'
}

c_js_compressor $@ || exit

# Development test case.

tst_syntax()
{
# ISO C macro defines require at least one space near "(", f.e: #define macro_w_no_param (1234+192)
# and one after macro's name
# white spaces around, between syntax tokens; skipping string expressions
    TST_SP_O='a = "|B != 4; |"; c = a + "| ; |" + f + "| ; |"; g = 789;  j++ ; \n
#define macro_no_param   (   1234 + 4321) \n
# define    marbe(param)     param (df  ) ;   j++; \n
d = m ( d + "= 1 + 3 +  5  =", 5 + 6 + " 13   5" + "ddr  ", 90, "k + 8", k - 1 + 2)  ; \n
\n
#line "4567"\n
d="must not be joined with splash "\n
if ( 1 ) { var i = 0; };
\n
# define A\t    ( -1 )\n
#define B()    (  -2  )\n
#define C()    {  j++  }\n
#define B()    do {   }  while  (  0  ) \n
\n
d = fun(   a, d,   f, 1  +  4 - 1   );  ++f = 1;\n
'
    TST_SP='if(  0  ) { a = "" ; }'
    echo -e "Test:\n$TST_SP_O\n===*==="
    echo -en $TST_SP_O |
    sed -r '
# step 1: splitting (with splashes)strings on new lines
# Note: string right before line end is spletted with only one splash
/".*[^"][ \t]*$/s_("[^"]+")_\\\n\1\\\n_g
/.*"[ \t]*$/s_("[^"]+")_\\\n\1\n_g
#             ! zero length lines
/".*"/s_("[^"]*")_\\\n\1\\\n_g' | sed -r '
# step 2: precess all lines without strings, to match C macro "#" added here
/^[^"]+$/{
# non strings
s_[ \t]*([]#<>~![+=*/?|&:;,}-])[ \t]*_\1_g
##s_^[ \t]*(#[a-zA-Z0-9_]+)[ \t]+([a-zA-Z0-9_]+)[ \t]+([({])[ \t]*_\1 \2 \3_g;
}
/^#/{
# C macroses require space after macro name
# for : "#define A (-1)" to not to be "#define A(-1)"
s_[ \t]+([({])[ \t]*_ \1_g
s_([)])[ \t]+_\1 _g
# spaces after
s_([{(])[ \t]+_\1_g
s_[ \t]+([)])_\1_g
}
/^[^#]/{
/^[^#]/{s_[ \t]*([(){]+)[ \t]*_\1_g;}
# old2 non macroses
#s_[ \t]+([({])[ \t]*_\1_g
#s_([)])[ \t]+_\1_g
# spaces after
#s_([{(])[ \t]+_\1_g
#s_[ \t]+([)])_\1_g
}
## old (for all)
#s_[ \t]*([]#<>~![+=*/?|&:;,{}-])[ \t]*_\1_g
#s_[ \t]+[(][ \t]*_ (_g
#s_[)][ \t]+[ \t]*_) _g
'
}

tst_c_comments()
{
# C-like comments, even with "/*" and "\" inside and not matching regexp like "/.*/"
     TST_CC='/* rf */ __g__ /* * * /  /* // \* \ /*  */ __a = 0;__ /* del /*
	     me*/ __d = /.*/;__ /* /*del*/ __kk__ /*del*/ /*del*/
	     s = "after comment block";
#define c_comment_with_strays \\
	/* macro coment stray \\
	   line               \\
	   end */ \\
	do { body(); };

int main(void) {}
'
     echo -e "Example:====\n$TST_CC\n===*==="
     echo -e "$TST_CC" | sed -r '
# step 1: break all "/*" on new lines
s_(/\*)_\\\n\1\n_g
' $1 | sed -r '
# step 2: match the largest(regexp feature) line range and "*/" -> "*/\n"
/\/\*/,/\*\//{
s_(\*/)_\n\1\n_
}' | sed -r '
# step 3: now comments are on new lines completely, remove
/\/\*/,/\*\//d'
}

tst_cpp_comments()
{
# C++ comments on the end of line, not matching regexp like /\//
    TST_CPPC="d = 123;\n// C++ comment //  /// jkioj ////// / // /// fdgf\n++d;"
# C++ comments on the beginning of line
    echo -e "Example:===\n"$TST_CPPC"\n===*==="
    echo -e $TST_CPPC | sed -r '
/^\/\//d'
    TST_CPPC="d = 123; /\//.test();// C++ comment\na = /[olecom]/// C++ comment // // dfr\nd++;"
    echo -e "Example:===\n"$TST_CPPC"\n===*==="
    echo -e $TST_CPPC | sed -r '
s/([^\\])\/\/[^\/].*$/\1/
'
}

tst_indent()
{
    TST_I='\n\n\r\n \tLine = "Line";\r\n   \r\n'
    echo -e "Example:====\n"$TST_I"\n===*==="
    echo -e $TST_I | sed -r '
# indentation
s_^[ \t]*__
# blank lines with "\r\n"
/^[\t\r ]*$/d'
}

tst_j_splash()
{
# join lines there're some strays(backslashes) one is as: "baf = \"
# Note: test has doubled strays, they're expanded to single on output
    TST_JLINE='
line 1\\
joined line 2\\
joined line 3
\\
new prejoin \\
j1
n2

n3
'
    echo -e "Test:\n$TST_JLINE\n===*===" "$@"
    echo -e "$TST_JLINE" "$@" | sed -r '
# found line with backslash on its tail, white spaces are possible
/\\[ \t]*$/ {
:more;
# append next line
N;
# replace backslash
s_\\[ \t]*\n__g;
# if sucsessfull repeat it once more
t more;
};
# if next line, join too
/\\[ \t]*$/bmore;
'
}

tst_join_lines()
{
# join lines, except C preprocessor directives,
# Note: /[^};]/ joined with additional space
    TST_JOIN='if(a){printf("dd");}a;'
    TST_JOIN2='
/* fff            \n
efwef*/           \n
#define C         \n
		  \n
#if defined(C)    \n
		  \n
#   error "be-be" \n
#endif            \n
# define JJ       \n
int\n
fun(void);        \n
#define A         \n
j2;\n
{ j2;\n
j5;\n
}                 \n
FALD\n
NOT\n
_		  \n
if (1) {
var i = 1;
}
\n
'
    echo -e "$TST_JOIN\n===*==="
    echo -e "$TST_JOIN" |\
    sed -r -n '
:join
/^#/{
p
n
}
# if only one line on input, print it
$p
# Note: after appending next line regexp tokens like "^" and "$"
#       should be used with care, "\n" becomes valid
N
/[\n]?#/{p;n}
s_[ \t]*([{};])[ \t]*\n[ \t]*_\1_g
s_[ \t]*([0-9a-zA-Z_*])[ \t]*\n_\1 _g
#$p it was doubleing of last line ;-)
b join
'
}
## parsing chain in compressor:
##

# C comments are splash depend on jline
#tst_j_splash "$(tst_c_comments $@)"

#tst_cpp_comments $@

#tst_indent

#tst_syntax

##this is after syntax string split
#tst_j_splash

#tst_join_lines

