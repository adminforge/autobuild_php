#!/bin/bash

LASTVERSION=$(ls -1d /opt/php-* | tail -n1)
CURRENTPHP=$($LASTVERSION/bin/php -v | grep PHP | head -n1 | cut -d" " -f2)
PHPVERSION=$(curl -s https://www.php.net/downloads.php | grep "Current Stable" -A1 | grep PHP | cut -d" " -f6)

if [ $PHPVERSION != $CURRENTPHP ]; then
	read -p"Neue PHP Version $PHPVERSION verfügbar ($CURRENTPHP). Aktualisieren (j/n)? " response
	if [ "$response" == "j" ]; then

	# update php
	cd /usr/local/src/php7.3-build
	wget https://www.php.net/distributions/php-$PHPVERSION.tar.gz
	tar xf php-$PHPVERSION.tar.gz
	cd php-$PHPVERSION

	# build php
	if [ $(grep -E "Debian|Ubuntu" /etc/*-release | wc -l) -ge 1 ]; then
	./configure --prefix=/opt/php-7.3 --with-pdo-pgsql --with-zlib-dir --with-freetype-dir --enable-mbstring --with-libxml-dir=/usr --enable-soap --enable-calendar --with-curl --with-zlib --with-gd --with-pgsql --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --enable-exif --enable-bcmath --with-mhash --enable-zip --with-pcre-regex --with-pdo-mysql --with-mysqli --with-mysql-sock=/var/run/mysqld/mysqld.sock --with-jpeg-dir=/usr --with-png-dir=/usr --with-openssl --with-fpm-user=www-data --with-fpm-group=www-data --with-libdir=/lib/x86_64-linux-gnu --enable-ftp --with-imap --with-imap-ssl --with-kerberos --with-gettext --with-xmlrpc --with-xsl --enable-opcache --enable-intl --enable-fpm --with-ldap
	elif [ $(grep -E "CentOS" /etc/*-release | wc -l) -ge 1 ]; then
	./configure --prefix=/opt/php-7.3 --with-zlib-dir --with-freetype-dir --enable-mbstring --with-libxml-dir=/usr --enable-soap --enable-calendar --with-curl --with-zlib --with-gd --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --enable-exif --enable-bcmath --with-mhash --enable-zip --with-pcre-regex --with-pdo-mysql --with-mysqli --with-mysql-sock=/var/run/mysqld/mysqld.sock --with-jpeg-dir=/usr --with-png-dir=/usr --with-openssl --with-fpm-user=www-data --with-fpm-group=www-data --with-libdir=/lib64 --enable-ftp --with-imap --with-imap-ssl --with-kerberos --with-gettext --with-xmlrpc --with-xsl --enable-opcache --enable-intl --enable-fpm --with-ldap
	else
	exit 1
	fi
	make -j4
	make install

	# update php-redis module
	cd /usr/local/src/php7.3-build/phpredis
	git pull
	/opt/php-7.3/bin/phpize
	./configure --with-php-config=/opt/php-7.3/bin/php-config
	make -j4
	make install

	# update php-apcu module
	cd /usr/local/src/php7.3-build/apcu
	git pull
	/opt/php-7.3/bin/phpize
	./configure --with-php-config=/opt/php-7.3/bin/php-config
	make -j4
	make install

	# update php-imagick module
	IMAGICKSTABLE=$(curl -s https://pecl.php.net/package/imagick | grep "stable" -A2 | head -n3 | grep -o "imagick-.*.tgz" | cut -d">" -f2 | sed 's/\.tgz//')
	cd /usr/local/src/php7.3-build
	wget https://pecl.php.net/get/$IMAGICKSTABLE.tgz -O $IMAGICKSTABLE.tgz
	tar xf $IMAGICKSTABLE.tgz
	cd /usr/local/src/php7.3-build/$IMAGICKSTABLE
	/opt/php-7.3/bin/phpize
	./configure --with-php-config=/opt/php-7.3/bin/php-config
	make -j4
	make install

	# restart php
	systemctl restart php7.3-fpm.service
	fi
else
	echo "Keine neue PHP Version verfügbar ($CURRENTPHP)."
fi
