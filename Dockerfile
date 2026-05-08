FROM php:8.5.5-zts-alpine

RUN apk --no-cache add linux-headers && \
    docker-php-ext-install sockets && \
    apk del linux-headers

RUN apk --no-cache add $PHPIZE_DEPS libev-dev libev && \
    pecl install ev parallel && \
    docker-php-ext-enable ev parallel && \
    apk del $PHPIZE_DEPS libev-dev

COPY --from=composer:2.9.7 /usr/bin/composer /usr/local/bin/composer
