FROM php:8.5.9 AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
        autoconf \
        dpkg-dev \
        file \
        g++ \
        gcc \
        libc-dev \
        make \
        pkg-config \
        libzip-dev \
        re2c \
        git \
        libssl-dev \
        libnghttp2-dev \
        libpq-dev \
        libc-ares-dev \
        liburing-dev \
        libcurl4-openssl-dev \
        linux-libc-dev

RUN docker-php-ext-install sockets
RUN docker-php-ext-install zip

RUN git clone https://github.com/openswoole/ext-openswoole.git && \
    cd ext-openswoole && \
    git checkout v26.2.0 && \
    phpize && \
    ./configure --enable-openssl \
                --enable-sockets \
                --enable-http2 \
                --enable-hook-curl \
                --with-postgres \
                --enable-io-uring \
                --enable-cares && \
    make -j$(nproc) && \
    make install

FROM php:8.5.9

RUN apt-get -y update --fix-missing && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends \
        libssl3 \
        libnghttp2-14 \
        libpq5 \
        libc-ares2 \
        liburing2 \
        libcurl4 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/

RUN echo "extension=sockets.so" > /usr/local/etc/php/conf.d/10-sockets.ini && \
    echo "extension=openswoole.so" > /usr/local/etc/php/conf.d/20-openswoole.ini

RUN docker-php-ext-enable zip

COPY --from=composer:2.10.2 /usr/bin/composer /usr/local/bin/composer
