#!/bin/bash

print_help() {
  echo "Usage: $0 [-h HOSTNAME] -u USERNAME -p PASSWORD"
  exit 2
}

count=0
MYSQL_USER=""
MYSQL_PASS=""
MYSQL_HOST=127.0.0.1

while getopts "u:p:h:" c; do
  case $c in
    u) MYSQL_USER=$OPTARG ;;
    p) MYSQL_PASS=$OPTARG ;;
    h) MYSQL_HOST=$OPTARG ;;
    *) print_help ;;
  esac
done

while true; do
  if [ "$count" -eq 30 ]; then
    echo 'Mysql not ready, bailing'
    exit 1
  elif mysql -u"$MYSQL_USER" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -e "quit" >>/dev/null 2>&1; then
    echo 'Mysql ready'
    exit 0
  fi

  sleep 1
  count=$((count+1))
done
