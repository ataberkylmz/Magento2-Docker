service ssh start

grep "xdebug" /usr/local/etc/php/php.ini > /dev/null 2>&1
XDEBUG_ENABLED=$?

if [ $XDEBUG_ENABLED -eq 0 ]; then
	echo "xdebug is already configured in php.ini"
else
	echo "Configuring xdebug in php.ini"
	XDEBUG_LOCATION=$(find /usr -type f | grep "xdebug.so")

	echo "[xdebug]
zend_extension=\"$XDEBUG_LOCATION\"
xdebug.remote_host=$XDEBUG_REMOTE_HOST
xdebug.remote_port=$XDEBUG_REMOTE_PORT
xdebug.idekey=$XDEBUG_IDEKEY 
xdebug.remote_enable=1
" >> /usr/local/etc/php/php.ini

fi
