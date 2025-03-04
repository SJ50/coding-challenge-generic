#!/usr/bin/env bash
COUNT_GREATER_THAN=2
FOLDER_PATH=$1

grep -r -o -h -E "(\w)+" $FOLDER_PATH |
    sort -f |
    uniq -c -i |
    sort -k1,1 -n |
    awk -v COUNT_GREATER_THAN=$COUNT_GREATER_THAN 'BEGIN {FS=" "; OFS=","; print "count,word"} $1 > COUNT_GREATER_THAN {gsub(/^[ \t]+/, "", $1); $2=$2; print}' |
    column -t -s ','

# explaination
#
# grep: (-r) recusive, (-o) output matching words only, (-h) do not print filename,
#       -E "(\w)+" match (letters, digits, underscores) using egrep
#       use "(\S)+" to match word separated by white space
#
# sort: (-f) sort words case-insensitive
#
# uniq: (-c) count uniq word, (-i) case-insensitive
#
# sort: (-k1,1) sort first colum, (-n) sort numerically
#
# awk: (-v) pass variable, (BEGIN {FS=" "; OFS=","; print "count,word"}) set FS to space and OFS to "," and print header,
#      ($1 > COUNT_GREATER_THAN) Filters rows where the count (first column) is greater than $COUNT_GREATER_THAN,
#      (gsub(/^[ \t]+/, "", $1)) Removes leading whitespace from the count column,
#      ($2=$2) record formatting,
#      (print) Outputs
#
# column: (-t) formats output, (-s) set column separater
#
