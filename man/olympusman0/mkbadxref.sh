#! /bin/sh
# mkbadxref - takes the output from mkmanxref and makes sure that all
# 	      the referenced pages exist.  Writes a list of those that
#	      don't to stdout.
#
# Usage: mkbadxref mkmanxref.out
#
# Thu Apr 10 01:08:07 1986  Charles (Herb) Kuta at SGI  (olympus!kuta)
#
# $Revision: 1.1 $
# $Date: 89/03/27 16:39:40 $
#
tmp1=/tmp/bx$$a

trap "rm -f $tmp1 ; exit 1" 2 3 15

if [ $# -ne 1 ] ; then
    echo  'Usage: mkbadxref mkmanxref.out'
    exit 1
fi

find ../[gua]_man ../troff \( -name '*.[1-8]' -o -name '*.[1-8][a-z]' \) -print \
    | sed 's:.*/::' \
    | sort -u \
    | sed 's/$/ xx/' > $tmp1

sed 's/^\([^(]*\)(\([^)]*\))	*\(.*\)$/\1 \2 \1(\2) \3/' $1 \
    | awk '{ print substr($1,1,9) "." $2; print $3; print $4 }' \
    | sed 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/;N;N;p;d' \
    | paste - - - \
    | sort -b \
    | join -a1 - $tmp1 \
    | awk '$NF != "xx" { print $2, $3 }' \
    | sort -b

rm -f $tmp1 
exit 0
