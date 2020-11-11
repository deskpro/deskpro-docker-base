#!/bin/sh

PWD="$(pwd)"

# Configure mysqldump
cat > ~/.my.cnf << EOF
[mysqldump]
host=$MYSQL_HOST
user=$MYSQL_USER
password=$MYSQL_PASS
EOF

chmod 600 ~/.my.cnf

# Create dir path if one doesn't exist
mkdir -p "$(dirname "${BACKUP_PATH}")"

# Dump DB as a single transaction to facilitate a hot backup
mysqldump --single-transaction --skip-lock-tables "${MYSQL_DBNAME}" | zip > "${BACKUP_PATH}"

# Name the SQL dump within the archive (using DB name)
printf "@ -\n@=database.sql\n" | zipnote -w "${BACKUP_PATH}"

# Optionally add attachments to the archive
if [ "${BACKUP_ATTACHMENTS}" = true ] ; then
  cd "${ATTACHMENTS_PATH}"
  cd ../
  zip -urq "${BACKUP_PATH}" "$(basename "${ATTACHMENTS_PATH}")"
  cd "${PWD}"
fi
