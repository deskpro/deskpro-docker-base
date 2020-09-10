cat << EOF > /etc/php/conf.d/zz-02-logging.ini
log_errors=On
error_reporting=${PHP_ERROR_REPORTING:-E_ALL}
EOF
