#!/usr/bin/env bash

checkParameter
clearCache
mysql -h mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS $SHOPWARE_PROJECT"
cd "/var/www/html/${SHOPWARE_PROJECT}"

php psh.phar unit