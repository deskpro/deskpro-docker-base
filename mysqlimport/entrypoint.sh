#!/bin/sh

# Configure mysql client
cat > ~/.my.cnf << EOF
[client]
host=$MYSQL_HOST
user=$MYSQL_USER
password=$MYSQL_PASS
EOF

chmod 600 ~/.my.cnf

# Unzip the DB dump and pipe into MySQL
unzip -p "${BACKUP_ARTIFACT_PATH}" "${BACKUP_DB_DUMP_NAME}" | mysql "${MYSQL_DBNAME}"
