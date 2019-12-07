FROM php:7.3-fpm-alpine

ARG ALPINE_MIRROR=https://mirrors.aliyun.com
ARG TIMEZONE=Asia/Shanghai

COPY local /usr/local/

RUN set -xe; \
#Update the operating system CA certificate store
    update-ca-certificates; \
# Install Composer
    curl -fsSL https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; \
# Install PHPUnit
    curl -fsSL -o /usr/local/bin/phpunit "https://phar.phpunit.de/phpunit-7.phar"; \
# Add execute permission and check exists
    chmod a+x /usr/local/bin/*; \
    composer --version; \
#   composer config -g repo.packagist composer https://packagist.phpcomposer.com; \
    phpunit --version; \
# Switch to a mirror if given
    if [ -n "$ALPINE_MIRROR" ]; then \
        ALPINE_MIRROR=${ALPINE_MIRROR//\//\\\/}; \
        sed -i "s/http:\/\/dl-cdn.alpinelinux.org/$ALPINE_MIRROR/g" /etc/apk/repositories; \
    fi; \
# Install build dependency packages
    apk update; \
    apk add --no-cache --virtual .php-rundeps freetype libpng libjpeg-turbo rabbitmq-c icu-libs yaml libzip; \
    apk add --no-cache --virtual .phpize-deps-configure $PHPIZE_DEPS tzdata \
# amqp
    rabbitmq-c-dev \
# swoole
    linux-headers \
# gd
    freetype-dev libjpeg-turbo-dev \
# soap
    libxml2-dev \
# intl
    icu-dev \
# yaml
    yaml-dev \
# zip
    libzip-dev; \
# Setup timezone
    if [ -n "$TIMEZONE" ]; then \
        cp "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime; \
        echo "$TIMEZONE" > /etc/timezone; \
    fi; \
# Install PHP extensions
    for PKG_FILE in /usr/local/tmp/*; \
    do \
        pear install "$PKG_FILE"; \
    done; \
    rm -rf /usr/local/tmp; \
    docker-php-ext-enable redis amqp; \
    docker-php-ext-configure gd --with-freetype-dir=/usr/lib/ --with-jpeg-dir=/usr/lib/; \
    docker-php-ext-configure zip --with-libzip=/usr/lib; \
    docker-php-ext-install bcmath gd mysqli pcntl pdo_mysql soap zip intl sockets; \
    docker-php-source delete; \
    cat /usr/local/etc/php/conf.d/docker-php-ext-* > /usr/local/etc/php/conf.d/docker-php-ext.ini; \
    rm /usr/local/etc/php/conf.d/docker-php-ext-*; \
# Cleanup
    rm -rf /tmp/pear; \
    rm -rf /usr/local/include; \
# System configurations
    addgroup -g 501 -S www; \
    adduser -u 501 -D -S -G www www; \
    sed -i "s/user = www-data/user = www/g" /usr/local/etc/php-fpm.d/www.conf; \
    sed -i "s/group = www-data/group = www/g" /usr/local/etc/php-fpm.d/www.conf; \
    sed -i "s/access.log = \/proc\/self\/fd\/2/access.log = \/proc\/self\/fd\/1/g" /usr/local/etc/php-fpm.d/docker.conf; \
    echo "pm.status_path = /status" >> /usr/local/etc/php-fpm.d/docker.conf; \
    mkdir -p /data1/www

WORKDIR /data1/www

EXPOSE 9000

ENTRYPOINT ["docker-php-entrypoint"]

CMD ["php-fpm"]