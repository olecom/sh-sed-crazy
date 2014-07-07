olecom(){
sed -n '
/^#/{
s-#--
h
:_append
N
/BLANK$/d
/\n$/d
s`\n` `
p
g
b_append
}'
}

gudermez(){
sed -e '
/^#[1-9][0-9]*$/{
s/.//
h
d
}
/^BLANK$/d
G
s/^\(.*\)\n\(.*\)/\2 \1/
'
}

echo "$1" >&2
$1 << '~'
#100
ADD some/file/path
MODIFY diff/file/path
BLANK

#104
MODIFY /another/modified/file/path
DEL /a/deleted/file/path
MODIFY /one/more/file/path
BLANK
#177
MODIFY /77another/modified/file/path
DEL /77a/deleted/file/path
MODIFY /77one/more/file/path
BLANK

#000
BLANK
~
exit

sed -e '# by gudermez
  ## strip off the leading hash & store in hold space
  /^#[1-9][0-9]*$/{
     s/.//;h;d
  }

  ## skip processing the BLANK line
  /^BLANK$/d

  ## for any other lines:
## PS => MODIFY diff/file/path

  G; ## append the hold space(contains the number, remember)
## PS => MODIFY diff/file/path\n100$

  s/^\(.*\)\n\(.*\)/\2 \1/; ## bring the number in front & remove \n
## PS => 100 MODIFY diff/file/path

  ## the default action of sed is print the pattern space
  ## which is what it does
' <<'~'
#100
ADD some/file/path
MODIFY diff/file/path
BLANK
#104
MODIFY /another/modified/file/path
DEL /a/deleted/file/path
MODIFY /one/more/file/path
BLANK
~
