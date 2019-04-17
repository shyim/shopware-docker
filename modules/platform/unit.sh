#!/usr/bin/env bash

checkParameter
clearCache
mysql -h mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS $SHOPWARE_PROJECT"
cd "/var/www/html/${SHOPWARE_PROJECT}"

if [[ $3 == "--with-coverage" ]]; then
    php -d pcov.enabled=1 -d pcov.directory=/var/www/html/${SHOPWARE_PROJECT} vendor/bin/phpunit -c vendor/shopware/platform/phpunit.xml.dist --coverage-clover build/artifacts/phpunit.clover.xml --coverage-html build/artifacts/phpunit-coverage-html ${@:4}
else
    php vendor/bin/phpunit -c vendor/shopware/platform/phpunit.xml.dist ${@:3}
fi