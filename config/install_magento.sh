#!/bin/bash

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

exec apache2-foreground
