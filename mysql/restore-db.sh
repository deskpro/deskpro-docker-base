#!/bin/bash

print_help() {
  echo "Usage: $0 -s FROM_DB -d TO_DB"
  exit 2
}

FROM_DB=""
TO_DB=""

while getopts "u:p:h:s:d:" c; do
  case $c in
    s) FROM_DB=$OPTARG ;;
    d) TO_DB=$OPTARG ;;
    *) print_help ;;
  esac
done

mysqladmin -f drop "$TO_DB"
mysqladmin create "$TO_DB"
mysqldump "$FROM_DB" | mysql "$TO_DB"
