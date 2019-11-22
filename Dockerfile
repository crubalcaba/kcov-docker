FROM debian:10-slim AS builder
WORKDIR /usr/local/src
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes \
 && apt-get update && apt-get install -y \
      build-essential cmake ninja-build python python3 \
      binutils-dev libcurl4-openssl-dev zlib1g-dev libdw-dev libiberty-dev
ARG VERSION=v37
ADD https://github.com/SimonKagstrom/kcov/archive/$VERSION.tar.gz /
RUN tar xzf /$VERSION.tar.gz -C ./ --strip-components 1 \
 && echo "Build kcov $VERSION" && mkdir build && cd build \
 && cmake -G 'Ninja' .. && cmake --build . --target install

FROM debian:10-slim
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NOWARNINGS=yes \
 && apt-get update && apt-get install -y binutils libcurl4 zlib1g libdw1 \
 && apt-get clean && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/bin/kcov* /usr/local/bin/
COPY --from=builder /usr/local/share/doc/kcov /usr/local/share/doc/kcov
CMD ["/usr/local/bin/kcov"]
