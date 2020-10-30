FROM alpine:3.12.1

RUN apk add --no-cache mysql-client gzip

ENTRYPOINT /usr/bin/mysqldump -h$MYSQL_HOST -u$MYSQL_USER -p$MYSQL_PASS $MYSQL_DBNAME | /usr/bin/gzip > $DUMP_PATH
