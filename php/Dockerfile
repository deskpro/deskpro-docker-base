FROM alpine:3.13 AS build
WORKDIR /root

ARG PHP_VERSION=7.4.14

# Apply stack smash protection to functions using local buffers and alloca()
# Make PHP's main executable position-independent (improves ASLR security mechanism, and has no performance impact on x86_64)
# Enable optimization (-O2)
# Enable linker optimization (this sorts the hash buckets to improve cache locality, and is non-default)
# https://github.com/docker-library/php/issues/272
# -D_LARGEFILE_SOURCE and -D_FILE_OFFSET_BITS=64 (https://www.php.net/manual/en/intro.filesystem.php)
ENV CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV CPPFLAGS="$CFLAGS"
ENV LDFLAGS="-Wl,-O1 -pie"

RUN apk --no-cache add \
    alpine-sdk \
    autoconf \
    bison \
    re2c \
    curl \
    curl-dev \
    libxml2 \
    libxml2-dev \
    oniguruma \
    oniguruma-dev \
    krb5 \
    krb5-dev \
    libpng \
    libpng-dev \
    libjpeg-turbo \
    libjpeg-turbo-dev \
    freetype \
    freetype-dev \
    c-client \
    imap-dev \
    icu \
    icu-dev \
    libldap \
    openldap-dev \
    libsodium \
    libsodium-dev \
    libzip \
    libzip-dev \
    gnu-libiconv \
    gnu-libiconv-dev

ADD https://www.php.net/distributions/php-$PHP_VERSION.tar.gz /root/
RUN mkdir php-$PHP_VERSION && tar -xzf /root/php-$PHP_VERSION.tar.gz -C php-$PHP_VERSION --strip-components 1

WORKDIR /root/php-$PHP_VERSION
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
RUN rm -f /etc/php/php-fpm.conf.default
RUN rm -f /etc/php/php-fpm.d/*
RUN rm -f /usr/lib/php/extensions/*/*.a

FROM alpine:3.13

ARG UID=82
ARG USER=php
ARG GID=82
ARG GROUP=php

ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so

RUN apk --no-cache add \
    curl \
    gettext \
    curl \
    libxml2 \
    oniguruma \
    krb5 \
    libpng \
    libjpeg-turbo \
    freetype \
    c-client \
    icu \
    libldap \
    libsodium \
    libzip \
    gnu-libiconv

RUN mkdir -p /etc/php/
RUN mkdir -p /usr/lib/php/extensions
RUN mkdir -p /etc/php/conf.d

COPY --from=build /usr/bin/php /usr/bin/
COPY --from=build /usr/sbin/php-fpm /usr/sbin/
COPY --from=build /etc/php /etc/php
COPY --from=build /usr/lib/php/extensions/ /usr/lib/php/extensions

RUN for ext in /usr/lib/php/extensions/*/*.so ; do filename=$(echo ${ext##*/}| cut -d'.' -f 1) ; \
    echo "extension=$filename" >> "/etc/php/conf.d/00-$filename.ini" ; done && \
    mv "/etc/php/conf.d/00-mysqlnd.ini" "/etc/php/conf.d/01-mysqlnd.ini" && \
    mv "/etc/php/conf.d/00-pdo_mysql.ini" "/etc/php/conf.d/02-pdo_mysql.ini" && \
    sed -i -e 's/extension/zend_extension/' /etc/php/conf.d/00-opcache.ini

# Create php user/group
RUN addgroup -g $GID $GROUP
RUN adduser -u $UID -g "PHP" -G $GROUP -h /var/lib/php -D -S $USER

COPY docker-entrypoint /etc/docker-entrypoint
RUN chmod a+x /etc/docker-entrypoint/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod a+x /usr/local/bin/entrypoint.sh

COPY php-fpm.conf.template /etc/php/php-fpm.conf.template
COPY www.conf.template /etc/php/php-fpm.d/www.conf.template

WORKDIR /srv
EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm", "-F"]
