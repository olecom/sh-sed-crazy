#!/bin/bash
## special for pulsar
## make cyrillic(cp1251) => ruglish filenames translation
## v 0.01 
## by olecom@gluon (C) 2003, copyleft GNU GPL
## NO WARRANTY, USE AT YOUR OWN RISK.
## based on dir.bash by olecom (C) 24/Oct/2001
##
# SYNOPSIS
# parse_fname.bash [cp koi] [dir_path] 
#

# russian in KOI8-R
UP_KOI='áâ÷çäå³öúéêëìíîïðòóôõæèãþûýÿùøüàñ'
DW_KOI='ÁÂ×ÇÄÅ£ÖÚÉÊËÌÍÎÏÐÒÓÔÕÆÈÃÞÛÝßÙØÜÀÑ'
# specials: £ÖÞÛÝßÙØÜÀÑ
UP_TRS='ABVGDEZIJKLMNOPRSTUFHC'
RU_TRS='ÁÂ×ÇÄÅÚÉÊËÌÍÎÏÐÒÓÔÕÆÈÃ'
DW_TRS='abvgdezijklmnoprstufhc'
# spesials: IOZHCHSHSCH\"Y\'\`EYUYA

# Save preset situation in tree 
exec_dir_save=$PWD

# Codepage to decode from
CP=$1
J=""
# Do transcoding
do_decode()
{
    T_FNAME=$(echo $1 | iconv -f $CP -t koi8-r | sed -e 'y/'$UP_KOI'/'$DW_KOI'/')
#    if ! [ `sed -e '/'$DW_KOI'/'` ]; then echo -e "no rus"; exit 1; fi
    #if [ $? ]; then echo "Maybe bad codepage input, exiting."; echo $T_FNAME ; exit 1; fi
    # specials:£ÖÞÛÝßÙØÜÀÑ |        
    echo $T_FNAME | sed -e '
    s/£/io/
    s/Ö/zh/
    s/Þ/ch/
    s/Û/sh/
    s/Ý/sch/
    s/ß/"/
    s/Ù/y/
    s/Ü/`e/
    s/À/yu/
    s/Ñ/ya/
    ' | sed -e "s/Ø/'/" | sed -e "y/'$RU_TRS'/'$DW_TRS'/" >/tmp/fname.tmp
    cat /tmp/fname.tmp
    echo "de^^^^^"
    mv $1 $(cat /tmp/fname.tmp)
}

# Function to go on recursively 
go_on()
{
    # Make a list of directory's entries 
    curlist=$(dir)
    for i in $curlist; do do_decode $i; done
    curlist=$(dir)
    for i in $curlist; do
        # is this one a (sub)directory 
        if [ -d $i ]; then
            # so report path and go on 
            #echo $i
	    cd $i
            go_on 
	    cd ..
        fi
    done
}

if [ "$CP" == "cp" ];  then
    CP="cp1251"
elif [ "$CP" == "koi" ]; then
    CP="koi8-r"
else
    echo -e "First parameter must to be \`cp' or \`koi'.\nSYNOPSIS\n\
	     parse_fname.bash [cp | koi] [dir_path]"
    exit 1
fi

if [ "$2" == "" ]; then
    echo -e "Second parameter must to be DIRECTORY PATH.\nSYNOPSIS\n\
	     parse_fname.bash [cp | koi] [dir_path]"
    exit 1
fi

# Go to start point 
cd $2

# Scanning... 
go_on
#do_decode $(find $2)

# Go back 
cd $exec_dir_save

# Free resources
rm /tmp/fname.tmp

# EOF
