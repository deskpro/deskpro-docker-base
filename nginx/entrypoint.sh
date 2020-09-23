#!/bin/sh
set -e

# Default variable values
export WORKER_PROCESSES=${WORKER_PROCESSES:-"auto"}

rm -f "/etc/nginx/sites-enabled/default"

# Produce a string list of each exported environment
# variable that has a name starting with DESKPRO_
exported_vars=$(env | sed -n 's/^\(DESKPRO_.*\)=.*/\1/p')
deskpro_var_list=""

for var in $exported_vars; do
  deskpro_var_list="$deskpro_var_list \$${var} "
done

# Generate the nginx master configuration
# file from the template file
envsubst '$WORKER_PROCESSES' < "/etc/nginx/nginx.conf.template" > "/etc/nginx/nginx.conf"

# Generate nginx config files for each template
# file found in the nginx config directory
for template_file in /etc/nginx/sites-available/*.template; do
  [ -f "$template_file" ] || continue

  config_file=$(echo "$template_file" | sed -e 's/\.template$//')
  envsubst "\$VIRTUAL_HOST \$FASTCGI_HOST $deskpro_var_list" < "$template_file" > "$config_file"

  config_filename=$(basename "$config_file")
  rm -f "/etc/nginx/sites-enabled/$config_filename"
  ln -s "$config_file" "/etc/nginx/sites-enabled/$config_filename"
done

exec "$@"