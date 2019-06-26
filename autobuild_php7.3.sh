#!/bin/bash

###
# autobuild php 7.3.4 for debian / ubuntu / centos
# (c) dominion 2019
###

if [ $(grep -E "Debian" /etc/*-release | wc -l) -ge 1 ]; then
	echo "install on debian linux ..."
	ln -s /usr/lib/libc-client.a /usr/lib/x86_64-linux-gnu/libc-client.a
	apt-get update
	apt-get install -y build-essential pkg-config autoconf libfcgi-dev libfcgi0ldbl libjpeg62-turbo-dev libmcrypt-dev libssl-dev libc-client2007e libc-client2007e-dev libxml2-dev libbz2-dev libcurl4-openssl-dev libjpeg-dev libpng-dev libfreetype6-dev libkrb5-dev libpq-dev libxml2-dev libxslt1-dev libzip-dev git libmagickwand-dev wget g++ libldap2-dev redis-server
elif [ $(grep -E "Ubuntu" /etc/*-release | wc -l) -ge 1 ]; then
	echo "install on ubuntu linux ..."
	ln -s /usr/lib/libc-client.a /usr/lib/x86_64-linux-gnu/libc-client.a
	apt-get update
	apt-get install -y build-essential pkg-config autoconf libfcgi-dev libfcgi0ldbl libmcrypt-dev libssl-dev libc-client2007e libc-client2007e-dev libxml2-dev libbz2-dev libcurl4-openssl-dev libjpeg-dev libpng-dev libfreetype6-dev libkrb5-dev libpq-dev libxml2-dev libxslt1-dev libzip-dev git libmagickwand-dev wget g++ libldap2-dev redis-server
elif [ $(grep -E "CentOS" /etc/*-release | wc -l) -ge 1 ]; then
	echo "install on centos linux ..."
	yum install -y epel-release
	yum install -y autoconf libxml2-devel libjpeg-devel libpng-devel libxml2-devel git ImageMagick-devel wget gcc openssl-devel libcurl-devel uw-imap-devel libc-client libicu-devel gcc-c++ libxslt-devel openldap-devel redis
	wget http://packages.psychotic.ninja/7/plus/x86_64/RPMS//libzip-0.11.2-6.el7.psychotic.x86_64.rpm
	wget http://packages.psychotic.ninja/7/plus/x86_64/RPMS//libzip-devel-0.11.2-6.el7.psychotic.x86_64.rpm
	rpm -i libzip-0.11.2-6.el7.psychotic.x86_64.rpm libzip-devel-0.11.2-6.el7.psychotic.x86_64.rpm
else
	echo "EXIT - no debian, ubuntu, centos or arch linux detected !"
exit 1
fi

cd /usr/include
ln -s x86_64-linux-gnu/curl

mkdir /opt/php-7.3
mkdir /usr/local/src/php7.3-build
cd /usr/local/src/php7.3-build
wget https://www.php.net/distributions/php-7.3.4.tar.gz -O php-7.3.4.tar.gz
tar xf php-7.3.4.tar.gz
cd php-7.3.4/

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

# copy configs
cp /usr/local/src/php7.3-build/php-7.3.4/php.ini-production /opt/php-7.3/lib/php.ini
cp /opt/php-7.3/etc/php-fpm.conf.default /opt/php-7.3/etc/php-fpm.conf
cp /opt/php-7.3/etc/php-fpm.d/www.conf.default /opt/php-7.3/etc/php-fpm.d/www.conf

sed -i 's#;pid = run/php-fpm.pid#pid = run/php-fpm.pid#g' /opt/php-7.3/etc/php-fpm.conf
sed -i 's#;error_log = log/php-fpm.log#error_log = log/php-fpm.log#g' /opt/php-7.3/etc/php-fpm.conf
sed -i 's#listen = 127.0.0.1:9000#listen = 127.0.0.1:9073#g' /opt/php-7.3/etc/php-fpm.d/www.conf
sed -i 's#memory_limit = 128M#memory_limit = 512M#g' /opt/php-7.3/lib/php.ini
sed -i 's#upload_max_filesize = 2M#upload_max_filesize = 512M#g' /opt/php-7.3/lib/php.ini
sed -i 's#short_open_tag = Off#short_open_tag = On#g' /opt/php-7.3/lib/php.ini
sed -i 's#expose_php = On#expose_php = Off#g' /opt/php-7.3/lib/php.ini
sed -i 's#;date.timezone.*#date.timezone = Europe\/\Berlin#g' /opt/php-7.3/lib/php.ini
sed -i 's#;opcache.enable=1#opcache.enable=1#g' /opt/php-7.3/lib/php.ini
sed -i 's#;opcache.enable_cli=0#opcache.enable_cli=1#g' /opt/php-7.3/lib/php.ini
sed -i 's#;opcache.memory_consumption=128#opcache.memory_consumption=128#g' /opt/php-7.3/lib/php.ini
sed -i 's#;opcache.interned_strings_buffer=8#opcache.interned_strings_buffer=8#g' /opt/php-7.3/lib/php.ini
sed -i 's#;opcache.max_accelerated_files=10000#opcache.max_accelerated_files=10000#g' /opt/php-7.3/lib/php.ini
sed -i 's#;opcache.revalidate_freq=2#opcache.revalidate_freq=1#g' /opt/php-7.3/lib/php.ini
sed -i 's#;opcache.save_comments=1#opcache.save_comments=1#g' /opt/php-7.3/lib/php.ini
sed -i 's#session.save_handler =.*#session.save_handler = redis\nsession.save_path = "tcp://127.0.0.1:6379"#g' /opt/php-7.3/lib/php.ini

sed -i '$aapc.enabled=1' /opt/php-7.3/lib/php.ini
sed -i '$aapc.file_update_protection=2' /opt/php-7.3/lib/php.ini
sed -i '$aapc.optimization=0' /opt/php-7.3/lib/php.ini
sed -i '$aapc.shm_size=256M' /opt/php-7.3/lib/php.ini
sed -i '$aapc.include_once_override=0' /opt/php-7.3/lib/php.ini
sed -i '$aapc.shm_segments=1' /opt/php-7.3/lib/php.ini
sed -i '$aapc.ttl=7200' /opt/php-7.3/lib/php.ini
sed -i '$aapc.user_ttl=7200' /opt/php-7.3/lib/php.ini
sed -i '$aapc.gc_ttl=3600' /opt/php-7.3/lib/php.ini
sed -i '$aapc.num_files_hint=1024' /opt/php-7.3/lib/php.ini
sed -i '$aapc.enable_cli=0' /opt/php-7.3/lib/php.ini
sed -i '$aapc.max_file_size=5M' /opt/php-7.3/lib/php.ini
sed -i '$aapc.cache_by_default=1' /opt/php-7.3/lib/php.ini
sed -i '$aapc.use_request_time=1' /opt/php-7.3/lib/php.ini
sed -i '$aapc.slam_defense=0' /opt/php-7.3/lib/php.ini
sed -i '$aapc.mmap_file_mask=/tmp/apc.XXXXXX' /opt/php-7.3/lib/php.ini
sed -i '$aapc.stat_ctime=0' /opt/php-7.3/lib/php.ini
sed -i '$aapc.canonicalize=1' /opt/php-7.3/lib/php.ini
sed -i '$aapc.write_lock=1' /opt/php-7.3/lib/php.ini
sed -i '$aapc.report_autofilter=0' /opt/php-7.3/lib/php.ini
sed -i '$aapc.rfc1867=0' /opt/php-7.3/lib/php.ini
sed -i '$aapc.rfc1867_prefix =upload_' /opt/php-7.3/lib/php.ini
sed -i '$aapc.rfc1867_name=APC_UPLOAD_PROGRESS' /opt/php-7.3/lib/php.ini
sed -i '$aapc.rfc1867_freq=0' /opt/php-7.3/lib/php.ini
sed -i '$aapc.rfc1867_ttl=3600' /opt/php-7.3/lib/php.ini
sed -i '$aapc.lazy_classes=0' /opt/php-7.3/lib/php.ini
sed -i '$aapc.lazy_functions=0' /opt/php-7.3/lib/php.ini

# create systemd unit
cat <<EOF > /etc/systemd/system/php7.3-fpm.service
[Unit]
Description=The PHP 7.3 FastCGI Process Manager
After=network.target
[Service]
Type=simple
PIDFile=/opt/php-7.3/var/run/php-fpm.pid
ExecStart=/opt/php-7.3/sbin/php-fpm --nodaemonize --fpm-config /opt/php-7.3/etc/php-fpm.conf
ExecReload=/bin/kill -USR2 $MAINPID
[Install]
WantedBy=multi-user.target
EOF

# install php-redis module
cd /usr/local/src/php7.3-build
git clone https://github.com/phpredis/phpredis.git
cd /usr/local/src/php7.3-build/phpredis
/opt/php-7.3/bin/phpize
./configure --with-php-config=/opt/php-7.3/bin/php-config
make -j4
make install

# install php-apcu module
cd /usr/local/src/php7.3-build
git clone https://github.com/krakjoe/apcu.git
cd /usr/local/src/php7.3-build/apcu
/opt/php-7.3/bin/phpize
./configure --with-php-config=/opt/php-7.3/bin/php-config
make -j4
make install

# install php-imagick module
cd /usr/local/src/php7.3-build
wget https://pecl.php.net/get/imagick-3.4.3.tgz -O imagick-3.4.3.tgz
tar xf imagick-3.4.3.tgz
cd /usr/local/src/php7.3-build/imagick-3.4.3
/opt/php-7.3/bin/phpize
./configure --with-php-config=/opt/php-7.3/bin/php-config
make -j4
make install

# add php modules to php.ini
cat <<EOF >> /opt/php-7.3/lib/php.ini
zend_extension=opcache.so
extension=redis.so
extension=apcu.so
extension=imagick.so
EOF

# enable & start service
systemctl daemon-reload
systemctl enable redis.service redis-server.service
systemctl start redis.service redis-server.service
systemctl enable php7.3-fpm.service
systemctl start php7.3-fpm.service

# run php version
/opt/php-7.3/bin/php -v

# show our modules
echo ""
echo "running custom modules:"
/opt/php-7.3/bin/php -m | egrep 'redis|apcu|imagick'
