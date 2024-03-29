FROM php:8.1-apache
LABEL maintainer="Ata Berk YILMAZ <me@ataberkylmz.com>"

ENV MAGENTO_HOST="<will be defined>" \
DB_SERVER="<will be defined>" \
DB_PORT=3306 \
DB_NAME=magento \
DB_USER=magento \
DB_PASSWORD=magento \
DB_PREFIX=m2_ \
ELASTICSEARCH_SERVER="<will be defined>" \
ELASTICSEARCH_PORT=9200 \
ELASTICSEARCH_INDEX_PREFIX=magento2 \
ELASTICSEARCH_TIMEOUT=15 \
ADMIN_NAME=admin \
ADMIN_LASTNAME=admin \
ADMIN_EMAIL=admin@example.com \
ADMIN_USERNAME=admin \
ADMIN_PASSWORD=admin123 \
ADMIN_URLEXT=admin \
MAGENTO_LANGUAGE=en_US \
MAGENTO_CURRENCY=EUR \
MAGENTO_TZ=Europe/Amsterdam \
DEPLOY_SAMPLEDATA=0 \
USE_SSL=0

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
		cron \
		unzip 

RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install -j$(nproc) bcmath gd intl pdo_mysql simplexml soap sockets xsl zip

COPY config/php.ini /usr/local/etc/php/
COPY config/install_magento.sh /tmp/install_magento.sh

RUN if [ -x "$(command -v apache2-foreground)" ]; then a2enmod rewrite; fi

ADD https://github.com/magento/magento2/archive/refs/tags/2.4.4.tar.gz /tmp/magento.tar.gz
ADD https://github.com/magento/magento2-sample-data/archive/refs/tags/2.4.4.tar.gz /tmp/sample-data.tar.gz

RUN chmod +x /tmp/install_magento.sh

CMD ["bash", "/tmp/install_magento.sh"]
