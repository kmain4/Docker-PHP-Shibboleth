#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "$1" == apache2* ]] || [ "$1" = 'php-fpm' ]; then
	uid="$(id -u)"
	gid="$(id -g)"
	if [ "$uid" = '0' ]; then
		case "$1" in
			apache2*)
				user="${APACHE_RUN_USER:-www-data}"
				group="${APACHE_RUN_GROUP:-www-data}"

				# strip off any '#' symbol ('#1000' is valid syntax for Apache)
				pound='#'
				user="${user#$pound}"
				group="${group#$pound}"
				;;
			*) # php-fpm
				user='www-data'
				group='www-data'
				;;
		esac
	else
		user="$uid"
		group="$gid"
	fi
    service shibd restart
	if [ -n "$SERVICE_URL" ]; then 
                rm /etc/apache2/sites-enabled/000-default.conf 
                echo "<VirtualHost *:80>" >> /etc/apache2/sites-enabled/000-default.conf  
                echo "   ServerName https://$SERVICE_URL" >> /etc/apache2/sites-enabled/000-default.conf  
                echo "   ServerAlias $SERVICE_URL" >> /etc/apache2/sites-enabled/000-default.conf  
                echo "   ServerAdmin webmaster@$SERVICE_URL" >> /etc/apache2/sites-enabled/000-default.conf  
                echo "   DocumentRoot /var/www/html" >> /etc/apache2/sites-enabled/000-default.conf  
                echo '   ErrorLog ${APACHE_LOG_DIR}/error.log' >> /etc/apache2/sites-enabled/000-default.conf  
                echo '   CustomLog ${APACHE_LOG_DIR}/access.log combined' >> /etc/apache2/sites-enabled/000-default.conf 
       		echo "</VirtualHost>" >> /etc/apache2/sites-enabled/000-default.conf 
        fi
fi

exec "$@"
