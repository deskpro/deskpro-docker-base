#!/bin/sh
set -e

for source_file in /etc/docker-entrypoint/*; do
  echo "Running entry point script: $source_file"
  chmod a+x "$source_file"
  . "$source_file"
done

exec "$@"
