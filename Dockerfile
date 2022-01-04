FROM php:7.4-apache
LABEL maintainer="Ata Berk YILMAZ <me@ataberkylmz.com>"

ENV MAGENTO_HOST="<will be defined>" \
DB_SERVER="<will be defined>" \
DB_NAME=magento \
DB_USER=magento \
DB_PASSWORD=magento \
DB_PREFIX=M2 \
ADMIN_NAME="<will be defined>" \
ADMIN_LASTNAME="<will be defined>" \
ADMIN_EMAIL="<will be defined>" \
ADMIN_USERNAME=admin \
ADMIN_PASSWORD=admin123 \
ADMIN_URLEXT=admin \
MAGENTO_LANGUAGE=en_US \
MAGENTO_CURRENCY=EUR \
MAGENTO_TZ=Europe/Amsterdam

RUN apt-get update \
	&& apt-get install -y libjpeg62-turbo-dev \
		libpng-dev \
		libfreetype6-dev \
		libxml2-dev \
		libzip-dev \
		libssl-dev \
		libxslt-dev \
		default-mysql-client \
		wget \
    unzip 

RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install -j$(nproc) bcmath gd intl pdo_mysql simplexml soap sockets xsl zip

RUN echo "<?php phpinfo(); ?>" > index.php

COPY config/php.ini /usr/local/etc/php/

ADD https://github.com/magento/magento2/archive/refs/tags/2.4.2.tar.gz magento.tar.gz

EXPOSE 80
