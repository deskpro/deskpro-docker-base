#!/bin/bash

# Configure mysql client
cat > ~/.my.cnf << EOF
[client]
host=$MYSQL_HOST
user=$MYSQL_USER
password=$MYSQL_PASS
EOF

chmod 600 ~/.my.cnf

# Query for urls/domains in settings
read -r -d '' QUERY << EOM
SELECT
    (SELECT CONVERT(value USING utf8) FROM settings WHERE name = 'core.deskpro_url'),
    (SELECT GROUP_CONCAT(CONVERT(value USING utf8) SEPARATOR '\t') FROM settings_brand WHERE name = 'core.deskpro_url')
;
EOM

mysql "${MYSQL_DBNAME}" -e "${QUERY}" -B -N > "${OUTPUT_PATH}"

# Query for site name
read -r -d '' QUERY << EOM
SELECT
    CONVERT(value USING utf8)
FROM
    settings
WHERE
    name = 'core.deskpro_name'
EOM

mysql "${MYSQL_DBNAME}" -e "${QUERY}" -B -N >> "${OUTPUT_PATH}"
