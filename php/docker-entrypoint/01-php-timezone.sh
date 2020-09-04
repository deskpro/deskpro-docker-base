if [ "$PHP_TIMEZONE" = "" ]; then
  PHP_TIMEZONE="UTC"
fi

cat << EOF > /etc/php/conf.d/zz-01-datetime.ini
date.timezone = $PHP_TIMEZONE
EOF
