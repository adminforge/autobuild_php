# autobuild_php.sh
This script will fully automated build the latest PHP-FPM and run it as systemd service.
Useful if the os version does not meet your requirements.

## Install
### Debian 9/10 / Ubuntu 18.04 / CentOS 7

1) download <code>autobuild_php.sh</code>
2) run it: <code>bash autobuild_php.sh install</code>
3) check if everything is fine in the summary
4) the script has been moved to /usr/local/bin/autobuild_php.sh
5) make your own settings: <code>/opt/php-7.3/etc/php-fpm.conf | /opt/php-7.3/etc/php-fpm.d/www.conf</code>


## Update

1) run the script to check if a new version is available: <code>autobuild_php.sh update</code>
3) if so, answer with "y" to update

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

### Systemd Timer (optional)
#### daily php version update check:

1) install systemd timer: <code>autobuild_php.sh installcron your@mailaddress.com</code>
2) verify that your system is able to send mails!
3) systemd timer and service file has been created
4) timer has been started

### Cronjob (optional)
#### daily php version update check:

1) add this line to your cronjobs <code>0    3    *    *    *    (/usr/local/bin/autobuild_php.sh cron) > /dev/null</code>
