#!/bin/sh
set -e

mkdir -p /opt/mutagen/scripts/
cp -R /usr/share/mutagen-scripts/* /opt/mutagen/scripts/

exec "$@"
