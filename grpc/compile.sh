#!/bin/sh
set -e

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

# Generate temp path for file generation
TMP_OUTPUT_DIRECTORY=$(mktemp -d)

# Generate files
find "$INPUT_DIRECTORY" -name "*.proto" -type f -prune -printf 'Building %p\n' -exec protoc \
   --proto_path="$INPUT_DIRECTORY" \
   --php_out="$TMP_OUTPUT_DIRECTORY" \
   --grpc_out="$TMP_OUTPUT_DIRECTORY" \
   --plugin=protoc-gen-grpc=/usr/bin/grpc_php_plugin \
   {} \;

# Relocate files, accounting for root namespace
rsync -a "$TMP_OUTPUT_DIRECTORY/$ROOT_NS_DIRECTORY" "$OUTPUT_DIRECTORY"

# Delete any temp files left behind
rm -rf "$TMP_OUTPUT_DIRECTORY"
