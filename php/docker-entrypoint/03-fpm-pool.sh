
# Set defaults
export FPM_MAX_CHILDREN=${FPM_MAX_CHILDREN:-5}
export FPM_START_SERVERS=${FPM_START_SERVERS:-2}
export FPM_MIN_SPARE_SERVERS=${FPM_MIN_SPARE_SERVERS:-1}
export FPM_MAX_SPARE_SERVERS=${FPM_MAX_SPARE_SERVERS:-3}
export FPM_PROCESS_IDLE_TIMEOUT=${FPM_PROCESS_IDLE_TIMEOUT:-"10s"}
export FPM_MAX_REQUESTS=${FPM_MAX_REQUESTS:-0}

envsubst '$FPM_MAX_CHILDREN $FPM_START_SERVERS $FPM_MIN_SPARE_SERVERS $FPM_MAX_SPARE_SERVERS $FPM_PROCESS_IDLE_TIMEOUT $FPM_MAX_REQUESTS' \
  < "/etc/php/php-fpm.d/www.conf.template" > "/etc/php/php-fpm.d/www.conf"

# Produce a string list of each exported environment
# variable that has a name starting with DESKPRO_
# Add the environment variable to fastcgi params as is
exported_vars=$(env | sed -n 's/^\(DESKPRO_[a-zA-Z0-9_]*\)=.*/\1/p')

for var_name in $exported_vars; do
  echo "env[${var_name}] = \$${var_name};" >> /etc/php/php-fpm.d/www.conf
done

# Produce a string list of each exported environment
# variable that has a name starting with ENV_
# Add the environment variable to fastcgi params with the prefix dropped
exported_vars=$(env | sed -n 's/^ENV_\([a-zA-Z0-9_]*\)=.*/\1/p')

for var_name in $exported_vars; do
  echo "env[${var_name}] = \$ENV_${var_name};" >> /etc/php/php-fpm.d/www.conf
done
