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
unzip -p "${BACKUP_PATH}" "${BACKUP_DB_DUMP_NAME}" | mysql "${MYSQL_DBNAME}"

# If archive contains attachments, install them
unzip -l "${BACKUP_PATH}" | grep -q "$(basename "${ATTACHMENTS_PATH}")"
if [ "$?" = "0" ] ; then
    unzip -o "${BACKUP_PATH}" "$(basename "${ATTACHMENTS_PATH}")/*" -d "${ATTACHMENTS_PATH}/../"
fi
