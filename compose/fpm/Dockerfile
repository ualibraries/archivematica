FROM php:7.0-fpm-alpine

RUN apk add --no-cache libmcrypt-dev \
                       pcre-dev \
                       ssmtp

RUN docker-php-ext-install pdo_mysql \
                           mcrypt \
                           opcache

ADD www-pool.conf /usr/local/etc/php-fpm.d/www.conf
ADD docker-entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

CMD ["php-fpm"]
