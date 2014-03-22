#!/bin/bash

echo "cd /tmp"
cd /tmp

echo "wget wordpress*.tar.gz"
wget http://ja.wordpress.org/wordpress-3.8.1-ja.tar.gz

echo "unarchive it";
tar xzf wordpress-3.8.1-ja.tar.gz

echo "mv wordpress /var/www"
mv wordpress /var/www
chown -R nginx.nginx /var/www/wordpress

echo "take backup of wp-config.php"
cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php
