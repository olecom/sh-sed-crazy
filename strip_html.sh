#!/bin/sh
#
# Time-stamp: "Sun May 11 06:45:22 CEST 2008 olecom@flower.upol.cz"

# No Copyright (C) XXI Oleg Verych, see http://sam.zoy.org/wtfpl/COPYING

#+ HTML comments
#+ non needed, repeated whitespace
# ---- is removed ----
#+ HTML <pre> tag content is the only, which is not touched, i.e. don't use
#  CSS "{ white-space: pre }" on other tags or add support for them yourself.

h=`printf '\001'`
HTML_COMMENTS="
# lang: HTML

# mark comment
s <!-- $h g;
s --> $h g;

# remove using shortest match
s $h[^$h]*$h  g;

# setup for next stage: <pre> is a 'display:block'
s [[:space:]]*<pre> \n<pre> g;
s </pre>[[:space:]]* </pre>\n g;
"
HTML_WITH_PRE="
:_start;
/<pre>/{
  :_nl;p;n;
  /<[/]pre>/!b_nl;
  b_start;
}
# outside <pre>, with non blank lines
# change (space and tabs) > 1 to one space, print
/^[[:space:]]*$/!{
  s_[[:blank:]]\{1,\}_ _g;
  p
}
"

sed ':nl;N;${'"$HTML_COMMENTS"'};bnl' << '</html>' | sed -n "$HTML_WITH_PRE"
<html>
<!-- crap -->

<!-- crap
special multiline crap -->

stuff
here


<pre>   3spaces left, right3   </pre>  bad  --  pre  is  block,  who  cares?
<pre>
    4spaces_left 4spaces_right    

    4spaces_left 4spaces_right    _

    4spaces_left 4spaces_right    !
</pre><!--       rm  -->
<pre>    4spaces4    </pre>  other   stuff<pre>    4spaces4    </pre>   ooo   <pre>
1    2

3    4
</pre>


3 (i.e. 4 times \n) newlines must be killed
EOF
</html>

exit

# Don't use it for shell scripts, whitespace matters there, and those scripts
# are usually not that big. Try to remove '^[:blank:]*#', in e.g. `configure`
# but this is not reliable also, due to possible here-doc delimiter or quotes.

# convert $h and $f to real symbols (too much quotes if "'" is used)
# S=`printf %s "$S" | sed 's $h '$h' g;s $f '$f' g;'`
# but for html '"' is OK for now.

# convert literals
s \([\'"'"']\)" \1'$q' g;

# lang: C
# convert symbols (NOTE: order matters!)
s '$c' /* g;
s // '$P' g;
s /\*/ '$p' g;
s /\* '$c' g;
s \*/ '$e' g;

s '$c'[^"]

s = "/*";

/* C crap, but it's "accepted" one
 */

S = "*/";

c = '"';
string = "     5spaces left double quote quoted \"     5spaces left and right    ";
javascript = "/* is crap, but leave it alone */";

html =   "is crap too <!-- but who cares? -->  2";

// C++ is crap
//* yes, it is
//*/ conformed

c++ = "//* no way!!!    5   3			3tabs   3*/"; // go away!




4newlines must be killed
EOF
!crap
