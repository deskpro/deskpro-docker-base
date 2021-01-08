
# Set defaults
export FPM_LOG_LEVEL=${FPM_LOG_LEVEL:-"notice"}

envsubst '$FPM_LOG_LEVEL' \
  < "/etc/php/php-fpm.conf.template" > "/etc/php/php-fpm.conf"
