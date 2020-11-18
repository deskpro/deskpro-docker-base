FROM ubuntu:20.04 AS build
WORKDIR /root

ENV DEBIAN_FRONTEND noninteractive

# Apply stack smash protection to functions using local buffers and alloca()
# Make PHP's main executable position-independent (improves ASLR security mechanism, and has no performance impact on x86_64)
# Enable optimization (-O2)
# Enable linker optimization (this sorts the hash buckets to improve cache locality, and is non-default)
# https://github.com/docker-library/php/issues/272
# -D_LARGEFILE_SOURCE and -D_FILE_OFFSET_BITS=64 (https://www.php.net/manual/en/intro.filesystem.php)
ENV CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV CPPFLAGS="$CFLAGS"
ENV LDFLAGS="-Wl,-O1 -pie"

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
    pkg-config \
    build-essential \
    autoconf \
    bison \
    re2c \
    curl \
    libcurl4-openssl-dev \
    autoconf \
    libxml2 \
    libxml2-dev \
    libonig5 \
    libonig-dev \
    libpng16-16 \
    libpng-dev \
    libjpeg-turbo8 \
    libjpeg-turbo8-dev \
    libsodium23 \
    libsodium-dev \
    libicu66 \
    libicu-dev \
    libldap-2.4-2 \
    libldap2-dev \
    libkrb5-3 \
    libkrb5-dev \
    libc-client2007e \
    libc-client2007e-dev \
    libzip5 \
    libzip-dev \
    libfreetype6 \
    libfreetype6-dev \
    && rm -rf /var/lib/apt/lists/*

ADD https://www.php.net/distributions/php-7.4.11.tar.gz /root/
RUN mkdir php-7.4.11 && tar -xzf /root/php-7.4.11.tar.gz -C php-7.4.11 --strip-components 1

WORKDIR /root/php-7.4.11
RUN ./buildconf --force
RUN ./configure \
    --with-fpm-user=php \
    --with-fpm-group=php \
    --prefix=/usr \
    --sysconfdir=/etc/php \
    --localstatedir=/var \
    --mandir=/usr/share/man \
    --with-config-file-path=/etc/php \
    --with-config-file-scan-dir=/etc/php/conf.d \
    --disable-all \
    --disable-cgi \
    --disable-phpdbg \
    --enable-fpm \
    --enable-opcache=shared \
    --with-openssl=shared \
    --with-iconv=shared \
    --with-zlib=shared \
    --with-libxml=shared \
    --with-jpeg=shared \
    --with-sodium=shared \
    --enable-json=shared \
    --enable-session=shared \
    --enable-ctype=shared \
    --enable-tokenizer=shared \
    --enable-simplexml=shared \
    --enable-mbstring=shared \
    --enable-xml=shared \
    --enable-dom=shared \
    --enable-filter=shared \
    --enable-pdo=shared \
    --with-pdo-mysql=shared,mysqlnd \
    --enable-gd=shared \
    --with-freetype=shared \
    --with-curl=shared \
    --enable-mysqlnd=shared \
    --enable-intl=shared \
    --enable-phar=shared \
    --with-ldap=shared \
    --enable-fileinfo=shared \
    --enable-xmlwriter=shared \
    --with-imap=shared \
    --with-imap-ssl=shared \
    --enable-soap=shared \
    --with-zip=shared \
    --with-kerberos=shared \
    --enable-posix=shared

RUN make -j$(nproc --all)
RUN make install
RUN mkdir -p /etc/php
RUN cp php.ini-production /etc/php/php.ini
RUN mv /etc/php/php-fpm.conf.default /etc/php/php-fpm.conf
RUN rm -f /etc/php/php-fpm.d/*
RUN rm -f /usr/lib/php/extensions/*/*.a






FROM ubuntu:20.04

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-suggests \
    curl \
    libxml2 \
    libonig5 \
    libpng16-16 \
    libjpeg-turbo8 \
    libsodium23 \
    libicu66 \
    libldap-2.4-2 \
    libkrb5-3 \
    libc-client2007e \
    libzip5 \
    gettext \
    libfreetype6 \
    supervisor \
    nginx-core \
    gettext \
    mysql-client-8.0 \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /etc/nginx/nginx.conf \
    && rm -f /etc/nginx/modules-enabled/50-mod-http-image-filter.conf \
    && rm -f /etc/nginx/modules-enabled/50-mod-http-xslt-filter.conf \
    && rm -f /etc/nginx/modules-enabled/50-mod-mail.conf \
    && rm -f /etc/nginx/modules-enabled/50-mod-stream.conf

RUN mkdir -p /etc/php/ \
    && mkdir -p /usr/lib/php/extensions \
    && mkdir -p /etc/php/conf.d

COPY --from=build /usr/bin/php /usr/bin/
COPY --from=build /usr/sbin/php-fpm /usr/sbin/
COPY --from=build /etc/php /etc/php
COPY --from=build /usr/lib/php/extensions/ /usr/lib/php/extensions

RUN for ext in /usr/lib/php/extensions/*/*.so ; do filename=$(echo ${ext##*/}| cut -d'.' -f 1) ; \
    echo "extension=$filename" >> "/etc/php/conf.d/00-$filename.ini" ; done && \
    mv "/etc/php/conf.d/00-mysqlnd.ini" "/etc/php/conf.d/01-mysqlnd.ini" && \
    mv "/etc/php/conf.d/00-pdo_mysql.ini" "/etc/php/conf.d/02-pdo_mysql.ini" && \
    sed -i -e 's/extension/zend_extension/' /etc/php/conf.d/00-opcache.ini

# Create phpfpm user/group
RUN groupadd -g 82 php
RUN useradd -u 82 -c "PHP Fast Process Manager" -g 82 -r -m -d /var/lib/php php

# Add main nginx config template
COPY nginx.conf.template /etc/nginx/nginx.conf.template

COPY docker-entrypoint /etc/docker-entrypoint
RUN chmod a+x /etc/docker-entrypoint/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod a+x /usr/local/bin/entrypoint.sh

COPY www.conf.template /etc/php/php-fpm.d/www.conf.template

RUN rm -f /var/log/php-fpm.log && ln -s /dev/stderr /var/log/php-fpm.log
RUN rm -f /var/log/supervisor/supervisord.log && ln -s /dev/stderr /var/log/supervisor/supervisord.log

COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY supervisor/* /etc/supervisor/conf.d/
COPY supervisord-exit-on-failure /usr/local/sbin/supervisord-exit-on-failure

RUN install -o root -g root -d -m 755 /run/php-fpm

WORKDIR /srv
EXPOSE 80
STOPSIGNAL SIGTERM
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
