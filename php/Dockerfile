FROM ubuntu:20.04 AS grpc_build
WORKDIR /root

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
    pkg-config \
    build-essential \
    autoconf \
    libtool \
    cmake \
    libssl-dev \
    git \
    zlib1g \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Compile and install gRPC library
WORKDIR /root
RUN git clone -b v1.32.0 --depth 1 --single-branch --recursive https://github.com/grpc/grpc

WORKDIR /root/grpc
RUN mkdir -p cmake/build

WORKDIR /root/grpc/cmake/build
RUN cmake \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_BUILD_TYPE=Release \
        -DgRPC_INSTALL=ON \
        -DBUILD_SHARED_LIBS=ON \
        -DgRPC_BUILD_TESTS=OFF \
        -DgRPC_BUILD_GRPC_CSHARP_PLUGIN=OFF \
        -DgRPC_BUILD_GRPC_NODE_PLUGIN=OFF \
        -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN=OFF \
        -DgRPC_BUILD_GRPC_PYTHON_PLUGIN=OFF \
        -DgRPC_BUILD_GRPC_RUBY_PLUGIN=OFF \
        -DgRPC_SSL_PROVIDER=package \
        -DgRPC_ZLIB_PROVIDER=package \
        ../../

# Use DESTDIR to allow a directory copy between images that leave
# symlinks intact whilst not copying unrelated files from the image
RUN DESTDIR=/root/grpc/INSTALLROOT make -j$(nproc --all) install

# Cleanup install base
WORKDIR /root/grpc/INSTALLROOT/
RUN find usr/lib -name *.a -type f -prune -exec rm -rf {} \;
RUN find usr/lib -name pkgconfig -type d -prune  -exec rm -rf {} \;
RUN find usr/lib -name cmake -type d -prune  -exec rm -rf {} \;


FROM ubuntu:20.04 AS php_build
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
    git \
    && rm -rf /var/lib/apt/lists/*

ADD https://www.php.net/distributions/php-7.4.5.tar.gz /root/
RUN mkdir php-7.4.5 && tar -xzf /root/php-7.4.5.tar.gz -C php-7.4.5 --strip-components 1

WORKDIR /root/php-7.4.5
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
    --enable-posix=shared \
    --with-pear

RUN make -j$(nproc --all)
RUN make install
RUN mkdir -p /etc/php
RUN cp php.ini-production /etc/php/php.ini
RUN mv /etc/php/php-fpm.conf.default /etc/php/php-fpm.conf
RUN rm -f /etc/php/php-fpm.d/*
RUN rm -f /usr/lib/php/extensions/*/*.a
RUN mkdir -p /etc/php/conf.d

RUN for ext in /usr/lib/php/extensions/*/*.so ; do filename=$(echo ${ext##*/}| cut -d'.' -f 1) ; \
    echo "extension=$filename" >> "/etc/php/conf.d/00-$filename.ini" ; done && \
    mv "/etc/php/conf.d/00-mysqlnd.ini" "/etc/php/conf.d/01-mysqlnd.ini" && \
    mv "/etc/php/conf.d/00-pdo_mysql.ini" "/etc/php/conf.d/02-pdo_mysql.ini" && \
    sed -i -e 's/extension/zend_extension/' /etc/php/conf.d/00-opcache.ini

# Copy grpc/protobuf dependencies
COPY --from=grpc_build /root/grpc/INSTALLROOT/ /

# Compile and install gRPC library
WORKDIR /root
RUN git clone -b v1.32.0 --depth 1 --single-branch --recursive https://github.com/grpc/grpc

# Compile and install the grpc php extension
WORKDIR /root/grpc/src/php/ext/grpc
RUN phpize
RUN ./configure
RUN make
RUN make install

WORKDIR /root
RUN git clone -b v3.13.0 --depth 1 --single-branch --recursive https://github.com/protocolbuffers/protobuf.git

# Compile and install the protobuf php extension
WORKDIR /root/protobuf/php/ext/google/protobuf

RUN phpize
RUN ./configure
RUN php make-preload.php
RUN make
RUN make install

# register grpc & protobuf extensions with php
RUN echo "extension=grpc" >> "/etc/php/conf.d/00-grpc.ini"
RUN echo "extension=protobuf" >> "/etc/php/conf.d/00-protobuf.ini"

FROM ubuntu:20.04

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
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
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/php/
RUN mkdir -p /usr/lib/php/extensions

COPY --from=php_build /usr/bin/php /usr/bin/
COPY --from=php_build /usr/sbin/php-fpm /usr/sbin/
COPY --from=php_build /etc/php /etc/php
COPY --from=php_build /usr/lib/php/extensions/ /usr/lib/php/extensions

# Copy grpc/protobuf dependencies
COPY --from=grpc_build /root/grpc/INSTALLROOT/usr/lib/ /usr/lib/
COPY --from=grpc_build /root/grpc/INSTALLROOT/usr/share/grpc/roots.pem /usr/share/grpc/roots.pem

# Create phpfpm user/group
RUN groupadd -g 82 php
RUN useradd -u 82 -c "PHP Fast Process Manager" -g 82 -r -m -d /var/lib/php php

COPY docker-entrypoint /etc/docker-entrypoint
RUN chmod a+x /etc/docker-entrypoint/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod a+x /usr/local/bin/entrypoint.sh

COPY www.conf.template /etc/php/php-fpm.d/www.conf.template
RUN ln -s /dev/stderr /var/log/php-fpm.log

WORKDIR /srv
EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm", "-F"]
