wget https://github.com/magento/magento2/archive/refs/tags/2.4.2.zip
unzip 2.4.2.zip
mv magento2-2.4.2/* ./
rm -rf magento2-2.4.2 2.4.2.zip

a2enmod rewrite
service apache2 restart

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer

composer intall -n

find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
chown -R www-data:www-data .
chmod u+x bin/magento

bin/magento setup:install \
--base-url=http://magento2.ataberkylmz.com \
--elasticsearch-host=elasticsearch \
--db-host=mysql \
--db-name=magento \
--db-user=magento \
--db-password=magento \
--admin-firstname=admin \
--admin-lastname=admin \
--admin-email=admin@admin.com \
--admin-user=admin \
--admin-password=admin123 \
--language=en_US \
--currency=USD \
--timezone=America/Chicago \
--use-rewrites=1

bin/magento setup:di:compile
bin/magento setup:static-content:deploy -f
bin/magento maintenance:disable

