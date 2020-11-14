#!/bin/sh
set -e

for source_file in /etc/docker-entrypoint/*; do
  chmod a+x "$source_file"
  . "$source_file"
done

exec "$@"
