FROM php:8.5.5-zts-alpine

RUN apk --no-cache add $PHPIZE_DEPS  linux-headers libev-dev openssl openssl-dev libev && \
    pecl install ev parallel && \
    docker-php-ext-enable parallel ev && \
    apk del $PHPIZE_DEPS libev-dev  linux-headers openssl-dev

COPY --from=composer:2.9.7 /usr/bin/composer /usr/local/bin/composer
