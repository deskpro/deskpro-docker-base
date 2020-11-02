#!/bin/sh

cat > ~/.my.cnf << EOF
[mysqldump]
host=$MYSQL_HOST
user=$MYSQL_USER
password=$MYSQL_PASS
EOF

chmod 600 ~/.my.cnf

mkdir -p "$(dirname "$DUMP_PATH")"

mysqldump --single-transaction --skip-lock-tables $MYSQL_DBNAME | zip > $DUMP_PATH

printf "@ -\n@=%s.sql\n" "$MYSQL_DBNAME" | zipnote -w $DUMP_PATH
