#!/bin/bash

if [ "$DB_SERVER" != "<will be defined>" ]; then
    RET=1
    while [ $RET -ne 0 ]; do
        echo "Checking if $DB_SERVER is available."
        mysql -h $DB_SERVER -u $DB_USER -p$DB_PASSWORD -e "status" > /dev/null 2>&1
        RET=$?

        if [ $RET -ne 0 ]; then
            echo "Connection to MySQL/MariaDB is pending."
            sleep 5
        fi
    done
        echo "DB server $DB_SERVER is available."
else
	echo "MySQL/MariaDB server is not defined!"
	exit 1
fi

if [ "$ELASTICSEARCH_SERVER" != "<will be defined>" ]; then
	RET=1
	while [ $RET -ne 0 ]; do
		echo "Checking if $ELASTICSEARCH_SERVER is available."
		curl -XGET "$ELASTICSEARCH_SERVER:9200/_cat/health?v&pretty" > /dev/null 2>&1
		RET=$?

		if [ $RET -ne 0 ]; then
			echo "Connection to Elasticsearch is pending."
			sleep 5
		fi
	done
		echo "Elasticsearch server $ELASTICSEARCH_SERVER is available."
else
	echo "Elasticsearch server is not defined!"
	exit 1
fi

if [[ -e ./pub/index.php ]]; then
        echo "Already extracted Magento"
else
        tar -xf magento.tar.gz --strip-components 1
        rm magento.tar.gz
fi

if [[ -e /usr/local/bin/composer ]]; then
        echo "Composer already exists"
else
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        php composer-setup.php --quiet
        rm composer-setup.php
        mv composer.phar /usr/local/bin/composer
fi

if [[ -d /var/www/html/vendor/magento ]]; then
	echo "Magento is already installed."
else
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
		bin/magento deploy:mode:set developer
		bin/magento maintenance:disable
		bin/magento cron:install

		echo "Installation completed"
fi

if [ $DEPLOY_SAMPLEDATA -eq 1 ]; then 
	if [[ -e ../sample-data.tar.gz ]]; then
		echo "Installing sample data"
		mkdir ../sample-data
		tar -xf ../sample-data.tar.gz --strip-components 1 -C ../sample-data
		rm ../sample-data.tar.gz
		php -f ../sample-data/dev/tools/build-sample-data.php -- --ce-source="/var/www/html"
		bin/magento setup:upgrade
	else
		echo "Sample data is already installed"
	fi
fi

ISSET_USE_SSL=$(bin/magento config:show web/secure/use_in_frontend)

if [ $USE_SSL -eq 1 ]; then
	if [ $ISSET_USE_SSL -eq 1  ]; then
		echo "Use SSL is set, but SSL is already enabled."
	else
		bin/magento setup:store-config:set \
			--base-url-secure="https://$MAGENTO_HOST" \
			--use-secure=1 \
			--use-secure-admin=1
		echo "SSL for Magento is configured."
	fi
else
	echo "Use SSL is not set, skipping."
fi

grep "ServerName" /etc/apache2/apache2.conf > /dev/null 2>&1
SERVERNAME_EXISTS=$?

if [ $SERVERNAME_EXISTS -eq 0 ]; then
	echo "ServerName is already added in Apache config."
else
	echo "ServerName $MAGENTO_HOST" >> /etc/apache2/apache2.conf
	echo "ServerName is added to Apache config."
fi

exec apache2-foreground
