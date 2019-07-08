#!/bin/bash

###
# autobuild php for latest debian / ubuntu / centos with systemd
# v1.0 (c) dominion 2019 | https://adminforge.de
###

# remember current directory for movement
CURRENTPWD=$(pwd)

# install curl
if [ $(which curl | wc -l) -eq 0 ]; then
echo "curl is missing, installing curl ..."
apt-get update >/dev/null 2>&1 && apt-get install -y curl >/dev/null 2>&1 || yum install -y curl >/dev/null 2>&1
fi

# get latest php version from local and php.net
LASTVERSION=$(stat /opt/php-* >/dev/null 2>&1 && ls -1d /opt/php-* | tail -n1)
CURRENTPHP=$($LASTVERSION/bin/php -v 2>/dev/null | grep PHP | head -n1 | cut -d" " -f2)
PHPVERSION=$(curl -s https://www.php.net/downloads.php | grep "Current Stable" -A1 | grep PHP | cut -d" " -f6)
PHPVERSIONSHORT=$(echo $PHPVERSION | cut -d"." -f1-2)



# check if php is already installed
check_php() {
if [ $(stat /opt/php-* 2>/dev/null | wc -l) -eq 0 ]; then
	echo "No PHP found, please install it first 'bash ${0##*/} install'."
	exit 1
fi
}



# build latest php version from php.net
install_latest() {
if [ $CURRENTPHP ]; then
	echo "PHP version $CURRENTPHP already installed, please use '${0##*/} update' to check for updates."
	exit 1
fi

# install dependencies
if [ $(grep -E "Debian" /etc/*-release | wc -l) -ge 1 ]; then
	echo "install on debian linux ..."
	ln -s /usr/lib/libc-client.a /usr/lib/x86_64-linux-gnu/libc-client.a 2>/dev/null
	apt-get update
	apt-get install -y build-essential pkg-config autoconf libfcgi-dev libfcgi0ldbl libjpeg62-turbo-dev libmcrypt-dev libssl-dev libc-client2007e libc-client2007e-dev libxml2-dev libbz2-dev libcurl4-openssl-dev libjpeg-dev libpng-dev libfreetype6-dev libkrb5-dev libpq-dev libxml2-dev libxslt1-dev libzip-dev git libmagickwand-dev wget g++ libldap2-dev redis-server bsd-mailx
elif [ $(grep -E "Ubuntu" /etc/*-release | wc -l) -ge 1 ]; then
	echo "install on ubuntu linux ..."
	ln -s /usr/lib/libc-client.a /usr/lib/x86_64-linux-gnu/libc-client.a 2>/dev/null
	apt-get update
	apt-get install -y build-essential pkg-config autoconf libfcgi-dev libfcgi0ldbl libmcrypt-dev libssl-dev libc-client2007e libc-client2007e-dev libxml2-dev libbz2-dev libcurl4-openssl-dev libjpeg-dev libpng-dev libfreetype6-dev libkrb5-dev libpq-dev libxml2-dev libxslt1-dev libzip-dev git libmagickwand-dev wget g++ libldap2-dev redis-server bsd-mailx
elif [ $(grep -E "CentOS" /etc/*-release | wc -l) -ge 1 ]; then
	echo "install on centos linux ..."
	yum install -y epel-release
	yum install -y autoconf libxml2-devel libjpeg-devel libpng-devel libxml2-devel git ImageMagick-devel wget gcc openssl-devel libcurl-devel uw-imap-devel libc-client libicu-devel gcc-c++ libxslt-devel openldap-devel redis mailx.x86_64
	wget http://packages.psychotic.ninja/7/plus/x86_64/RPMS//libzip-0.11.2-6.el7.psychotic.x86_64.rpm
	wget http://packages.psychotic.ninja/7/plus/x86_64/RPMS//libzip-devel-0.11.2-6.el7.psychotic.x86_64.rpm
	rpm -i libzip-0.11.2-6.el7.psychotic.x86_64.rpm libzip-devel-0.11.2-6.el7.psychotic.x86_64.rpm
	useradd www-data
else
	echo "EXIT - no debian, ubuntu, centos or arch linux detected !"
exit 1
fi

cd /usr/include
ln -s x86_64-linux-gnu/curl 2>/dev/null

mkdir /opt/php-$PHPVERSIONSHORT
mkdir /usr/local/src/php$PHPVERSIONSHORT-build
cd /usr/local/src/php$PHPVERSIONSHORT-build
wget https://www.php.net/distributions/php-$PHPVERSION.tar.gz -O php-$PHPVERSION.tar.gz
tar xf php-$PHPVERSION.tar.gz
cd php-$PHPVERSION/

# build php
if [ $(grep -E "Debian|Ubuntu" /etc/*-release | wc -l) -ge 1 ]; then
./configure --prefix=/opt/php-$PHPVERSIONSHORT --with-pdo-pgsql --with-zlib-dir --with-freetype-dir --enable-mbstring --with-libxml-dir=/usr --enable-soap --enable-calendar --with-curl --with-zlib --with-gd --with-pgsql --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --enable-exif --enable-bcmath --with-mhash --enable-zip --with-pcre-regex --with-pdo-mysql --with-mysqli --with-mysql-sock=/var/run/mysqld/mysqld.sock --with-jpeg-dir=/usr --with-png-dir=/usr --with-openssl --with-fpm-user=www-data --with-fpm-group=www-data --with-libdir=/lib/x86_64-linux-gnu --enable-ftp --with-imap --with-imap-ssl --with-kerberos --with-gettext --with-xmlrpc --with-xsl --enable-opcache --enable-intl --enable-fpm --with-ldap
elif [ $(grep -E "CentOS" /etc/*-release | wc -l) -ge 1 ]; then
./configure --prefix=/opt/php-$PHPVERSIONSHORT --with-zlib-dir --with-freetype-dir --enable-mbstring --with-libxml-dir=/usr --enable-soap --enable-calendar --with-curl --with-zlib --with-gd --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --enable-exif --enable-bcmath --with-mhash --enable-zip --with-pcre-regex --with-pdo-mysql --with-mysqli --with-mysql-sock=/var/run/mysqld/mysqld.sock --with-jpeg-dir=/usr --with-png-dir=/usr --with-openssl --with-fpm-user=www-data --with-fpm-group=www-data --with-libdir=/lib64 --enable-ftp --with-imap --with-imap-ssl --with-kerberos --with-gettext --with-xmlrpc --with-xsl --enable-opcache --enable-intl --enable-fpm --with-ldap
else
exit 1
fi

make -j4
make install

# copy configs
cp /usr/local/src/php$PHPVERSIONSHORT-build/php-$PHPVERSION/php.ini-production /opt/php-$PHPVERSIONSHORT/lib/php.ini
cp /opt/php-$PHPVERSIONSHORT/etc/php-fpm.conf.default /opt/php-$PHPVERSIONSHORT/etc/php-fpm.conf
cp /opt/php-$PHPVERSIONSHORT/etc/php-fpm.d/www.conf.default /opt/php-$PHPVERSIONSHORT/etc/php-fpm.d/www.conf

sed -i 's#;pid = run/php-fpm.pid#pid = run/php-fpm.pid#g' /opt/php-$PHPVERSIONSHORT/etc/php-fpm.conf
sed -i 's#;error_log = log/php-fpm.log#error_log = log/php-fpm.log#g' /opt/php-$PHPVERSIONSHORT/etc/php-fpm.conf
sed -i 's#listen = 127.0.0.1:9000#listen = 127.0.0.1:9073#g' /opt/php-$PHPVERSIONSHORT/etc/php-fpm.d/www.conf
sed -i 's#memory_limit = 128M#memory_limit = 512M#g' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i 's#upload_max_filesize = 2M#upload_max_filesize = 512M#g' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i 's#short_open_tag = Off#short_open_tag = On#g' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i 's#expose_php = On#expose_php = Off#g' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i 's#;date.timezone.*#date.timezone = Europe\/\Berlin#g' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i 's#;opcache.enable=1#opcache.enable=1#g' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i 's#;opcache.enable_cli=0#opcache.enable_cli=1#g' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i 's#;opcache.memory_consumption=128#opcache.memory_consumption=128#g' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i 's#;opcache.interned_strings_buffer=8#opcache.interned_strings_buffer=8#g' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i 's#;opcache.max_accelerated_files=10000#opcache.max_accelerated_files=10000#g' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i 's#;opcache.revalidate_freq=2#opcache.revalidate_freq=1#g' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i 's#;opcache.save_comments=1#opcache.save_comments=1#g' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i 's#session.save_handler =.*#session.save_handler = redis\nsession.save_path = "tcp://127.0.0.1:6379"#g' /opt/php-$PHPVERSIONSHORT/lib/php.ini

sed -i '$aapc.enabled=1' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.file_update_protection=2' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.optimization=0' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.shm_size=256M' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.include_once_override=0' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.shm_segments=1' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.ttl=7200' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.user_ttl=7200' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.gc_ttl=3600' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.num_files_hint=1024' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.enable_cli=0' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.max_file_size=5M' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.cache_by_default=1' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.use_request_time=1' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.slam_defense=0' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.mmap_file_mask=/tmp/apc.XXXXXX' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.stat_ctime=0' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.canonicalize=1' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.write_lock=1' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.report_autofilter=0' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.rfc1867=0' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.rfc1867_prefix =upload_' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.rfc1867_name=APC_UPLOAD_PROGRESS' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.rfc1867_freq=0' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.rfc1867_ttl=3600' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.lazy_classes=0' /opt/php-$PHPVERSIONSHORT/lib/php.ini
sed -i '$aapc.lazy_functions=0' /opt/php-$PHPVERSIONSHORT/lib/php.ini

# create systemd units
cat <<EOF > /etc/systemd/system/php$PHPVERSIONSHORT-fpm.service
[Unit]
Description=The PHP $PHPVERSIONSHORT FastCGI Process Manager
After=network.target

[Service]
Type=simple
PIDFile=/opt/php-$PHPVERSIONSHORT/var/run/php-fpm.pid
ExecStart=/opt/php-$PHPVERSIONSHORT/sbin/php-fpm --nodaemonize --fpm-config /opt/php-$PHPVERSIONSHORT/etc/php-fpm.conf
ExecReload=/bin/kill -USR2 $MAINPID

[Install]
WantedBy=multi-user.target
EOF

# install php-redis module
cd /usr/local/src/php$PHPVERSIONSHORT-build
git clone https://github.com/phpredis/phpredis.git
cd /usr/local/src/php$PHPVERSIONSHORT-build/phpredis
/opt/php-$PHPVERSIONSHORT/bin/phpize
./configure --with-php-config=/opt/php-$PHPVERSIONSHORT/bin/php-config
make -j4
make install

# install php-apcu module
cd /usr/local/src/php$PHPVERSIONSHORT-build
git clone https://github.com/krakjoe/apcu.git
cd /usr/local/src/php$PHPVERSIONSHORT-build/apcu
/opt/php-$PHPVERSIONSHORT/bin/phpize
./configure --with-php-config=/opt/php-$PHPVERSIONSHORT/bin/php-config
make -j4
make install

# install php-imagick module
IMAGICKSTABLE=$(curl -s https://pecl.php.net/package/imagick | grep "stable" -A2 | head -n3 | grep -o "imagick-.*.tgz" | cut -d">" -f2 | sed 's/\.tgz//')
cd /usr/local/src/php$PHPVERSIONSHORT-build
wget https://pecl.php.net/get/$IMAGICKSTABLE.tgz -O $IMAGICKSTABLE.tgz
tar xf $IMAGICKSTABLE.tgz
cd /usr/local/src/php$PHPVERSIONSHORT-build/$IMAGICKSTABLE
/opt/php-$PHPVERSIONSHORT/bin/phpize
./configure --with-php-config=/opt/php-$PHPVERSIONSHORT/bin/php-config
make -j4
make install

# add php modules to php.ini
cat <<EOF >> /opt/php-$PHPVERSIONSHORT/lib/php.ini
zend_extension=opcache.so
extension=redis.so
extension=apcu.so
extension=imagick.so
EOF

# enable & start service
systemctl daemon-reload
systemctl enable redis.service redis-server.service >/dev/null 2>&1
systemctl start redis.service redis-server.service >/dev/null 2>&1
systemctl enable php$PHPVERSIONSHORT-fpm.service >/dev/null 2>&1
systemctl start php$PHPVERSIONSHORT-fpm.service >/dev/null 2>&1

echo ""
echo "### Summary ###"

# run php version
echo ""
echo -n "installed php version:    "; /opt/php-$PHPVERSIONSHORT/bin/php -v | head -n1 | cut -d" " -f2

# show our modules
echo -n "installed custom modules: "; /opt/php-$PHPVERSIONSHORT/bin/php -m | egrep 'redis|apcu|imagick' | tr "\n" " "
echo ""

# show php-fpm systemd status
echo -n "php-fpm status:           "; systemctl status php$PHPVERSIONSHORT-fpm.service | grep Active | cut -d" " -f5-6 | tr "\n" " "
echo ""

# move script to the right place
if ! [ -f /usr/local/bin/${0##*/} ]; then
	echo -n "move script:              "; chmod +x $CURRENTPWD/${0##*/}; mv -v $CURRENTPWD/${0##*/} /usr/local/bin/
	echo ""
fi
}



# update to latest php version from php.net
update_latest() {
if [ $PHPVERSION != $CURRENTPHP ]; then
	read -p"New PHP version $PHPVERSION available ($CURRENTPHP). Update? (y/n) " response
	if [ "$response" == "y" ]; then

	# update php
	mkdir /usr/local/src/php$PHPVERSIONSHORT-build >/dev/null 2>&1
	mkdir /opt/php-$PHPVERSIONSHORT >/dev/null 2>&1
	cd /usr/local/src/php$PHPVERSIONSHORT-build
	wget https://www.php.net/distributions/php-$PHPVERSION.tar.gz
	tar xf php-$PHPVERSION.tar.gz
	cd php-$PHPVERSION

	# build php
	if [ $(grep -E "Debian|Ubuntu" /etc/*-release | wc -l) -ge 1 ]; then
	./configure --prefix=/opt/php-$PHPVERSIONSHORT --with-pdo-pgsql --with-zlib-dir --with-freetype-dir --enable-mbstring --with-libxml-dir=/usr --enable-soap --enable-calendar --with-curl --with-zlib --with-gd --with-pgsql --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --enable-exif --enable-bcmath --with-mhash --enable-zip --with-pcre-regex --with-pdo-mysql --with-mysqli --with-mysql-sock=/var/run/mysqld/mysqld.sock --with-jpeg-dir=/usr --with-png-dir=/usr --with-openssl --with-fpm-user=www-data --with-fpm-group=www-data --with-libdir=/lib/x86_64-linux-gnu --enable-ftp --with-imap --with-imap-ssl --with-kerberos --with-gettext --with-xmlrpc --with-xsl --enable-opcache --enable-intl --enable-fpm --with-ldap
	elif [ $(grep -E "CentOS" /etc/*-release | wc -l) -ge 1 ]; then
	./configure --prefix=/opt/php-$PHPVERSIONSHORT --with-zlib-dir --with-freetype-dir --enable-mbstring --with-libxml-dir=/usr --enable-soap --enable-calendar --with-curl --with-zlib --with-gd --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --enable-exif --enable-bcmath --with-mhash --enable-zip --with-pcre-regex --with-pdo-mysql --with-mysqli --with-mysql-sock=/var/run/mysqld/mysqld.sock --with-jpeg-dir=/usr --with-png-dir=/usr --with-openssl --with-fpm-user=www-data --with-fpm-group=www-data --with-libdir=/lib64 --enable-ftp --with-imap --with-imap-ssl --with-kerberos --with-gettext --with-xmlrpc --with-xsl --enable-opcache --enable-intl --enable-fpm --with-ldap
	else
	exit 1
	fi
	make -j4
	make install

	# update php-redis module
	cd /usr/local/src/php$PHPVERSIONSHORT-build/phpredis
	git pull
	/opt/php-$PHPVERSIONSHORT/bin/phpize
	./configure --with-php-config=/opt/php-$PHPVERSIONSHORT/bin/php-config
	make -j4
	make install

	# update php-apcu module
	cd /usr/local/src/php$PHPVERSIONSHORT-build/apcu
	git pull
	/opt/php-$PHPVERSIONSHORT/bin/phpize
	./configure --with-php-config=/opt/php-$PHPVERSIONSHORT/bin/php-config
	make -j4
	make install

	# update php-imagick module
	IMAGICKSTABLE=$(curl -s https://pecl.php.net/package/imagick | grep "stable" -A2 | head -n3 | grep -o "imagick-.*.tgz" | cut -d">" -f2 | sed 's/\.tgz//')
	cd /usr/local/src/php$PHPVERSIONSHORT-build
	wget https://pecl.php.net/get/$IMAGICKSTABLE.tgz -O $IMAGICKSTABLE.tgz
	tar xf $IMAGICKSTABLE.tgz
	cd /usr/local/src/php$PHPVERSIONSHORT-build/$IMAGICKSTABLE
	/opt/php-$PHPVERSIONSHORT/bin/phpize
	./configure --with-php-config=/opt/php-$PHPVERSIONSHORT/bin/php-config
	make -j4
	make install

	# restart php
	systemctl restart php$PHPVERSIONSHORT-fpm.service

	# run php version
	echo ""
	echo -n "installed php version:    "; /opt/php-$PHPVERSIONSHORT/bin/php -v | head -n1 | cut -d" " -f2

	# show our modules
	echo -n "installed custom modules: "; /opt/php-$PHPVERSIONSHORT/bin/php -m | egrep 'redis|apcu|imagick' | tr "\n" " "
	echo ""

	# list systemd timers
	echo -n "php-fpm status:           "; systemctl status php$PHPVERSIONSHORT-fpm.service | grep Active | cut -d" " -f5-6 | tr "\n" " "

	# show our modules
	echo ""
	echo "running custom modules:"
	/opt/php-$PHPVERSIONSHORT/bin/php -m | egrep 'redis|apcu|imagick'

	fi
else
	echo "No new PHP version available ($CURRENTPHP)."
fi
}



# install cronjob
install_cron() {
# set mail address for cronjob update notification
sed -i "0,/^MAILTO=/{s/^MAILTO=.*/MAILTO=$*/}" $0

# install systemd timer
cat <<EOF > /etc/systemd/system/check-php-version.timer
[Unit]
Description=Check PHP Version Timer

[Timer]
OnCalendar=*-*-* 00:00:00
RandomizedDelaySec=18000
Persistent=True

[Install]
WantedBy=timers.target
EOF

cat <<EOF > /etc/systemd/system/check-php-version.service
[Unit]
Description=Check PHP Version

[Service]
Type=simple
Nice=10
ExecStart=/usr/local/bin/autobuild_php.sh cron
EOF

systemctl enable check-php-version.timer >/dev/null 2>&1
systemctl start check-php-version.timer >/dev/null 2>&1

# list systemd timer
echo -n "systemd timer:            "; systemctl list-timers | grep check-php-version.timer | cut -d" " -f1-7
}



# cronjob with email php update alert
update_cron() {
MAILTO=root
if [ $PHPVERSION != $CURRENTPHP ]; then
	echo "New PHP version $PHPVERSION available ($CURRENTPHP) !" | mail -s "New PHP version $PHPVERSION available ($HOSTNAME)" $MAILTO
	exit 1
fi
}



case "$1" in
        install)
        install_latest
        ;;

        installcron)
	check_php
	if [ -z "$2" ]; then
		echo $"Something went wrong, example usage: "
		echo $"bash ${0##*/} installcron me@example.com"
	else
	install_cron "$2"
	fi
        ;;

        update)
	check_php
        update_latest
        ;;

        cron)
	check_php
        update_cron
        ;;

        *)
        echo $"Usage  : ${0##*/} {install|installcron|update|cron}"
        exit 1
esac
