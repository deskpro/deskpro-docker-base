#!/bin/sh
set -e

WATCHER_PID=""
WATCH=0

print_help() {
  echo "Usage: $0 [-w]"
  exit 2
}

while getopts "w" c; do
  case $c in
    w) WATCH=1 ;;
    *) print_help ;;
  esac
done

if [ $WATCH -eq 1 ]; then
  # If watching, start the watch process and listen for term signals
  term_handler() {
    if [ "$WATCHER_PID" != "" ]; then
      kill -TERM "$WATCHER_PID"
    fi
  }

  trap term_handler TERM

  bash -l -c "/usr/local/bin/watch.sh -i \"$INPUT_DIRECTORY\" -o \"$OUTPUT_DIRECTORY\" -n \"$ROOT_NS_DIRECTORY\"" & WATCHER_PID=$!
  wait "$WATCHER_PID"
else
  # If not watching, run a compile once directly
  /usr/local/bin/compile.sh -i "$INPUT_DIRECTORY" -o "$OUTPUT_DIRECTORY" -n "$ROOT_NS_DIRECTORY"
fi
