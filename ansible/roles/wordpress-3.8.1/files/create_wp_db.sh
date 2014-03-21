#!/bin/bash

echo /usr/bin/mysql -u root -p$MYSQL_ROOT_PASS -e"CREATE DATABASE wordpress"
/usr/bin/mysql -u root -p$MYSQL_ROOT_PASS -e"CREATE DATABASE wordpress"

echo /usr/bin/mysql -u root -p$MYSQL_ROOT_PASS -e"grant all privileges on wordpress.* to wordpressuser@localhost identified by '$MYSQL_WP_PASS'";
/usr/bin/mysql -u root -p$MYSQL_ROOT_PASS -e"grant all privileges on wordpress.* to wordpressuser@localhost identified by '$MYSQL_WP_PASS'";

echo /usr/bin/mysql -u root -p$MYSQL_ROOT_PASS -e"FLUSH PRIVILEGES"
/usr/bin/mysql -u root -p$MYSQL_ROOT_PASS -e"FLUSH PRIVILEGES"

