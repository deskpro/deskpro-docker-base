FROM alpine:3.12.1

RUN apk add --no-cache \
    mysql-client \
    zip

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod a+x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
