#!/bin/bash

if [[ -e ./pub/index.php ]]; then
        echo "Already extracted Magento"
else
        tar -xf magento.tar.gz --strip-components 1
        #rm magento.tar.gz
fi

APACHE_ERROR = 0
a2enmod -q rewrite || APACHE_ERROR = 1
apache2ctl -k graceful || APACHE_ERROR = 1

if [[ APACHE_ERROR -eq 1 ]]; then
        echo "APACHE THREW AN ERROR"
        exit 1
else
        echo "ENABLED REWRITE AND RESTARTED APACHE SUCCESSFULLY"
fi

if [[ -e /usr/local/bin/composer ]]; then
        echo "Composer already exists"
else
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        php composer-setup.php --quiet
        rm composer-setup.php
        mv composer.phar /usr/local/bin/composer
fi
