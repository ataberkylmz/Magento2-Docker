FROM ataberkylmz/magento2:2.4.0
LABEL maintainer="Ata Berk YILMAZ <me@ataberkylmz.com>"

ENV XDEBUG_CLIENT_HOST=localhost \
XDEBUG_CLIENT_PORT=9003 \
XDEBUG_IDEKEY="PHPSTORM" \
DEBUG_USERNAME=dev \
DEBUG_USERPASS=dev

RUN  apt-get install -y openssh-server \
		sudo

RUN pecl install xdebug-3.1.3 \
    && docker-php-ext-enable xdebug

COPY config/enable_debugging.sh /tmp/enable_debugging.sh

RUN chmod +x /tmp/install_magento.sh /tmp/enable_debugging.sh

RUN useradd -rm -d /home/$DEBUG_USERNAME -s /bin/bash -g root -G sudo -u 1000 $DEBUG_USERNAME
RUN echo "$DEBUG_USERNAME:$DEBUG_USERPASS" | chpasswd

CMD ["bash", "/tmp/install_magento.sh"]
