# php-7.3-autobuild
This script will fully automated build PHP-FPM 7.3.x and run it as systemd service.
Useful if the os version does not meet your requirements.

## Install
### Debian / Ubuntu / CentOS

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

### Nagios Plugin (optional)
#### NRPE Node

1) make the nagios plugin script executable: <code>chmod +x check_php_update</code>
2) move it to the plugin directory <code>mv check_php_update /usr/lib/nagios/plugins/</code>
3) add this line <code>command[check_php_update]=/usr/lib/nagios/plugins/check_php_update</code> to <code>/etc/nagios/nrpe.cfg</code>
4) restart nagios nrpe service: <code>systemctl restart nagios-nrpe-server.service</code>

#### Nagios Node
<pre>
define service{
        use                             generic-service
        host_name                       example.com
        service_description             PHP Update
        check_command                   check_nrpe_1arg!check_php_update
        }
</pre>
