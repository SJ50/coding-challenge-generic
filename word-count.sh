#!/usr/bin/env bash

set -euo pipefail
# error handling
function error_trap {
    if [ -o errexit ]; then
        line=$(caller | cut -d " " -f 1)
        script=$(caller | cut -d " " -f 2)
        (
            set +e
            echo "Error at ${line} in ${script}:"
        )
    fi
}
trap error_trap ERR

COUNT_GREATER_THAN=""
FOLDER_PATH=""

# flag to pass folder_path and count
while getopts ':hf:c:-:' OPTION; do
    case "$OPTION" in
    h)
        echo -e "script usage: \nbash $(basename $0) [-h] [-f|--folderpath FOLDER_PATH] [-c|--count COUNT]" >&2
        exit 1
        ;;
    f)
        FOLDER_PATH="$OPTARG"
        ;;
    c)
        COUNT_GREATER_THAN="$OPTARG"
        ;;
    -)
        case "$OPTARG" in
        folderpath)
            FOLDER_PATH="${!OPTIND}"
            OPTIND=$(($OPTIND + 1))
            ;;
        folderpath=*)
            FOLDER_PATH="${OPTARG#*=}"
            ;;
        count)
            COUNT_GREATER_THAN="${!OPTIND}"
            OPTIND=$(($OPTIND + 1))
            ;;
        count=*)
            COUNT_GREATER_THAN="${OPTARG#*=}"
            ;;
        *)
            echo "Invalid option: --$OPTARG" >&2
            echo -e "script usage: \nbash $(basename $0) [-h] [-f|--folderpath FOLDER_PATH] [-c|--count COUNT]" >&2
            exit 1
            ;;
        esac
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        echo -e "script usage: \nbash $(basename $0) [-h] [-f|--folderpath FOLDER_PATH] [-c|--count COUNT]" >&2
        exit 1
        ;;
    esac
done
shift "$(($OPTIND - 1))"

if [ -z "$FOLDER_PATH" ]; then
    echo "Error: Folder path is required. Use -f or --folderpath to specify." >&2
    exit 1
fi

if [ -z "$COUNT_GREATER_THAN" ]; then
    echo "Error: count is required. Use -c or --count to specify." >&2
    exit 1
fi

# script to find reoccurance of word
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
