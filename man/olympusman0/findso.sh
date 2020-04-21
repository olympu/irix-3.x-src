#! /bin/sh
# findso - find all man pages that have .so's
#
cd /pubs/irismanpgs
find [au]_man troff \( -name '*.[1-8]' -o -name '*.[1-8][a-z]' \) -print \
    | xargs egrep '\.so '
