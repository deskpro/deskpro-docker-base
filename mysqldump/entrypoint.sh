#!/bin/sh

# Configure mysqldump
cat > ~/.my.cnf << EOF
[mysqldump]
host=$MYSQL_HOST
user=$MYSQL_USER
password=$MYSQL_PASS
EOF

chmod 600 ~/.my.cnf

# Create dir path if one doesn't exist
mkdir -p "$(dirname "${DUMP_PATH}")"

# Dump DB as a single transaction to facilitate a hot backup
mysqldump --single-transaction --skip-lock-tables "${MYSQL_DBNAME}" | zip > "${DUMP_PATH}"

# Name the SQL dump within the archive (using DB name)
printf "@ -\n@=%s.sql\n" "${MYSQL_DBNAME}" | zipnote -w "${DUMP_PATH}"
