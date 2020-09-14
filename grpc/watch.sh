#!/bin/sh
set -e

VERBOSE=0
if [ "$VERBOSE" = "true" ]; then
  VERBOSE=1
fi

INPUT_DIRECTORY=""
OUTPUT_DIRECTORY=""
ROOT_NS_DIRECTORY=""

print_help() {
  echo "Usage: $0 -i INPUT_DIRECTORY -o OUTPUT_DIRECTORY [-n ROOT_NS_DIRECTORY]"
  exit 2
}

while getopts "i:o:n:" c; do
  case $c in
    i) INPUT_DIRECTORY=$OPTARG ;;
    o) OUTPUT_DIRECTORY=$OPTARG ;;
    n) ROOT_NS_DIRECTORY=$OPTARG ;;
    *) print_help ;;
  esac
done

echo "Watch directory: $INPUT_DIRECTORY"
echo "Build directory: $OUTPUT_DIRECTORY"
echo "Root directory: $ROOT_NS_DIRECTORY"

# First time compile
/usr/local/bin/compile.sh -i "$INPUT_DIRECTORY" -o "$OUTPUT_DIRECTORY" -n "$ROOT_NS_DIRECTORY"

# Then watch for changes
inotifywait -q -m -e modify -e attrib -e move -e create -e delete -e delete_self -e unmount "$INPUT_DIRECTORY" |
while read -r directory events filename; do
  if [ $VERBOSE -eq 1 ]; then
    echo "directory: $directory, events: $events, filename: $filename";
  fi

  /usr/local/bin/compile.sh -i "$INPUT_DIRECTORY" -o "$OUTPUT_DIRECTORY" -n "$ROOT_NS_DIRECTORY"
done
