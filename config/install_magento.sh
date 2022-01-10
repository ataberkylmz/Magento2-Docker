#!/bin/bash

if [[ -e ./pub/index.php ]]; then
        echo "Already extracted Magento"
else
        tar -xf magento.tar.gz --strip-components 1
        #rm magento.tar.gz
fi


# DO NOT DO IT HERE, But do it in Dockerfile.
APACHE_ERROR = 0
a2enmod -q rewrite || APACHE_ERROR = 1
apache2ctl -k graceful || APACHE_ERROR = 1

if [[ APACHE_ERROR -eq 1 ]]; then
        echo "APACHE THREW AN ERROR"
        exit 1
else
        echo "ENABLED REWRITE AND RESTARTED APACHE SUCCESSFULLY"
fi
#---

if [[ -e /usr/local/bin/composer ]]; then
        echo "Composer already exists"
else
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        php composer-setup.php --quiet
        rm composer-setup.php
        mv composer.phar /usr/local/bin/composer
fi

## Find a way yo see if Magento is already installed or not, if so skip
composer install -n

find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
chown -R www-data:www-data .
chmod u+x bin/magento

bin/magento setup:install \
--base-url=http://$MAGENTO_HOST \
--elasticsearch-host=$ELASTICSEARCH_SERVER \
--db-host=$DB_SERVER \
--db-name=$DB_NAME \
--db-user=$DB_USER \
--db-password=$DB_PASSWORD \
--db-prefix=$DB_PREFIX \
--admin-firstname=$ADMIN_NAME \
--admin-lastname=$ADMIN_LASTNAME \
--admin-email=$ADMIN_EMAIL \
--admin-user=$ADMIN_USERNAME \
--admin-password=$ADMIN_PASSWORD \
--backend-frontname=$ADMIN_URLEXT \
--language=en_US \
--currency=EUR \
--timezone=Europe/Amsterdam \
--use-rewrites=1 \
--cleanup-database

bin/magento setup:di:compile
bin/magento setup:static-content:deploy -f
bin/magento indexer:reindex
bin/magento cache:clean
bin/magento cache:flush
rm -rf generated/metadata/* generated/code/*
bin/magento deploy:mode:set developer
bin/magento maintenance:disable
bin/magento sampledata:deploy
bin/magento cron:install


# DO NOT DO IT HERE, but create another image based on this Magento image.
composer require adyen/module-payment -n
bin/magento module:enable Adyen_Payment
bin/magento setup:upgrade
