FROM ubuntu:20.04
WORKDIR /root

# Install nginx and disable unnecessary services
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
    nginx-core \
    gettext \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /etc/nginx/nginx.conf \
    && rm -f /etc/nginx/modules-enabled/50-mod-http-image-filter.conf \
    && rm -f /etc/nginx/modules-enabled/50-mod-http-xslt-filter.conf \
    && rm -f /etc/nginx/modules-enabled/50-mod-mail.conf \
    && rm -f /etc/nginx/modules-enabled/50-mod-stream.conf

# Add main nginx config template
COPY nginx.conf.template /etc/nginx/

# Add entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod a+x /usr/local/bin/entrypoint.sh

WORKDIR /srv
EXPOSE 80
STOPSIGNAL SIGTERM
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
