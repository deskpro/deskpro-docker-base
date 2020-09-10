cat << EOF > /etc/php/conf.d/zz-01-datetime.ini
date.timezone = ${PHP_TIMEZONE:-UTC}
EOF
