# from https://stackoverflow.com/questions/46786589/running-composer-install-within-a-dockerfile?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa

FROM php:7-fpm-alpine3.7

RUN apk add curl fcgi --no-cache \
  && curl -sS https://getcomposer.org/installer | php \
  && chmod +x composer.phar \
  && mv composer.phar /usr/local/bin/composer

RUN apk --no-cache add --virtual .build-deps $PHPIZE_DEPS \
  && apk --no-cache add --virtual .ext-deps libmcrypt-dev freetype-dev \
  libjpeg-turbo-dev libpng-dev libxml2-dev msmtp bash openssl-dev pkgconfig \
  && docker-php-source extract \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ \
                                   --with-png-dir=/usr/include/ \
                                   --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install gd mysqli pdo pdo_mysql zip opcache \
  && docker-php-ext-enable mysqli \
  && docker-php-ext-enable gd \
  && docker-php-ext-enable pdo \
  && docker-php-ext-enable pdo_mysql \
  && docker-php-source delete \
  && curl -Lo /usr/local/bin/php-fpm-healthcheck 'https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck' \
  && echo -e "pm.status_path = /status" >> /usr/local/etc/php-fpm.d/health.conf \
  && echo -e "ping.path = /ping"        >> /usr/local/etc/php-fpm.d/health.conf \
  && echo -e "ping.response = pong"     >> /usr/local/etc/php-fpm.d/health.conf \
  && chmod +x /usr/local/bin/php-fpm-healthcheck \
  && apk del .build-deps

WORKDIR /var/www/html

#COPY composer.json composer.lock ./
#RUN composer install --no-scripts --no-autoloader
#
#RUN chmod +x artisan
#
#RUN composer dump-autoload --optimize && composer run-script post-install-cmd
#
##CMD php artisan serve --host 0.0.0.0 --port 5001
#CMD bash -c "composer install && php artisan serve --host 0.0.0.0 --port 5001"
