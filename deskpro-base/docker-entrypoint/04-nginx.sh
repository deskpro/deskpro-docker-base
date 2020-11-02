#!/bin/sh
set -e

# Default variable values
export WORKER_PROCESSES=${WORKER_PROCESSES:-"auto"}

rm -f "/etc/nginx/sites-enabled/default"
rm -f /etc/nginx/deskpro_fastcgi_params
touch /etc/nginx/deskpro_fastcgi_params

# Produce a string list of each exported environment
# variable that has a name starting with DESKPRO_
# Add the environment variable to fastcgi params as is
exported_vars=$(env | sed -n 's/^\(DESKPRO_[a-zA-Z0-9_]*\)=.*/\1/p')

for var_name in $exported_vars; do
  eval var_value="\$${var_name}"
  echo "fastcgi_param ${var_name} \"${var_value}\";" >> /etc/nginx/deskpro_fastcgi_params
done

# Produce a string list of each exported environment
# variable that has a name starting with ENV_
# Add the environment variable to fastcgi params with the prefix dropped
exported_vars=$(env | sed -n 's/^ENV_\([a-zA-Z0-9_]*\)=.*/\1/p')

for var_name in $exported_vars; do
  eval var_value="\$ENV_${var_name}"
  echo "fastcgi_param ${var_name} \"${var_value}\";" >> /etc/nginx/deskpro_fastcgi_params
done

# Generate the nginx master configuration
# file from the template file
envsubst '$WORKER_PROCESSES' < "/etc/nginx/nginx.conf.template" > "/etc/nginx/nginx.conf"

# Generate nginx config files for each template
# file found in the nginx config directory
for template_file in /etc/nginx/sites-available/*.template; do
  [ -f "$template_file" ] || continue

  config_file=$(echo "$template_file" | sed -e 's/\.template$//')
  envsubst "\$VIRTUAL_HOST \$FASTCGI_HOST" < "$template_file" > "$config_file"

  config_filename=$(basename "$config_file")
  rm -f "/etc/nginx/sites-enabled/$config_filename"
  ln -s "$config_file" "/etc/nginx/sites-enabled/$config_filename"
done

exec "$@"
