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



FROM ubuntu:20.04
WORKDIR /root

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
    inotify-tools \
    rsync \
    && rm -rf /var/lib/apt/lists/*

# Copy grpc/protobuf dependencies
COPY --from=grpc_build /root/grpc/INSTALLROOT/ /

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod a+x /usr/local/bin/entrypoint.sh

COPY watch.sh /usr/local/bin/watch.sh
RUN chmod a+x /usr/local/bin/watch.sh

COPY compile.sh /usr/local/bin/compile.sh
RUN chmod a+x /usr/local/bin/compile.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
