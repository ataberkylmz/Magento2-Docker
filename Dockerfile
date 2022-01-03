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
	&& apt-get install -y libmcrypt-dev \
		libjpeg62-turbo-dev \
		libpcre3-dev \
		libpng-dev \
		libfreetype6-dev \
		libxml2-dev \
		libicu-dev \
		libzip-dev \
		libssl-dev \
		default-mysql-client \
		wget \
        unzip \
        libonig-dev

RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install bcmath ctype curl dom fileinfo gd hash iconv intl json libxml mbstring openssl pcre pdo_mysql simplexml soap sockets sodium xmlwriter xsl zip

EXPOSE 80
