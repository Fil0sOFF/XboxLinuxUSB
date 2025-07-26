#!/bin/bash

print_usage() {
        echo "Usage:    $0 <PATH>"
        echo '	Create initial folder stucture inside <PATH>'
        echo
}

err() {
        echo "Error: $1"
        exit 1
}

[ ! -d "$1" ] && print_usage && err "$1 is not a directory"

SCRIPTDIR="$(dirname -- "$(readlink -f -- "$0")")"
while read -r dir; do
        echo "Creating ${1}/${dir}"
        mkdir -p "${1}/${dir}"
done <"$SCRIPTDIR/dirs.txt"
