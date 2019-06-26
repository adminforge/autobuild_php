# php-7.3-autobuild
This script will fully automated build PHP-FPM 7.3.x and run it as systemd service.

## Install
### Debian / Ubuntu / CentOS

#### Included PHP Modules:
php-redis, php-apcu, php-imagick

1) download git repo
2) make the script executable: <code>chmod +x autobuild_php7.3.sh</code>
3) run it: ./autobuild_php7.3.sh
4) check the version: /opt/php-7.3/bin/php -v
5) make your own settings: /opt/php-7.3/etc/php-fpm.conf | /opt/php-7.3/etc/php-fpm.d/www.conf


## Update
### Debian / Ubuntu / CentOS

1) make the update script executable: <code>chmod +x update_php7.3.sh</code>
2) run the script to check if a new version is available: ./update_php7.3.sh
3) if so, answer with "j" to update
