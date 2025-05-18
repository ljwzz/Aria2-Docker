# 使用多阶段构建来减小镜像体积
FROM alpine:latest AS builder

# 设置构建参数，可传入aria2的release版本
ARG ARIA2_VERSION=1.37.0

# 安装构建依赖
RUN apk add --no-cache \
    g++ \
    make \
    autoconf \
    automake \
    libtool \
    gettext-dev \
    openssl-dev \
    zlib-dev \
    c-ares-dev \
    sqlite-dev \
    libssh2-dev \
    cppunit-dev \
    libxml2-dev

WORKDIR /tmp/aria2

RUN wget -O aria2-${ARIA2_VERSION}.tar.xz \
    "https://github.com/aria2/aria2/releases/download/release-${ARIA2_VERSION}/aria2-${ARIA2_VERSION}.tar.xz" \
    && tar -xf aria2-${ARIA2_VERSION}.tar.xz --strip-components=1 \
    && rm aria2-${ARIA2_VERSION}.tar.xz

RUN autoreconf -i \
    && ./configure \
        --prefix=/usr \
        --with-libxml2 \
        --with-openssl \
        --with-sqlite3 \
        --with-libz \
        --with-libcares \
        --with-libssh2 \
    && make -j$(nproc) \
    && make install-strip

# 最终镜像
FROM alpine:latest

# 复制构建好的aria2二进制文件
COPY --from=builder /usr/bin/aria2c /usr/bin/aria2c
COPY rootfs /

# 安装运行时依赖 sqlite libsqlite3
RUN apk add --no-cache libstdc++ openssl zlib c-ares sqlite-libs libssh2 libxml2 gettext \
    su-exec shadow tzdata curl jq \
    && addgroup -g 1000 runner \
    && adduser -D -u 1000 -G runner runner \
    && rm -rf /var/cache/apk/* /tmp/*

ENV CUSTOM_TRACKER_URL= \
    PUID= \
    PGID= \
    UMASK_SET="022" \
    TZ="Asia/Shanghai"

EXPOSE 6800 6888 6888/udp

VOLUME /config /downloads

# 设置入口点
ENTRYPOINT ["/aria2/main.sh"]
