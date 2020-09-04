FROM mysql:8.0

COPY restore-db.sh /usr/local/bin/restore-db
COPY wait-til-mysql-ready.sh /usr/local/bin/wait-til-mysql-ready
RUN chmod a+x /usr/local/bin/wait-til-mysql-ready /usr/local/bin/restore-db
