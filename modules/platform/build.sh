#!/usr/bin/env bash

checkParameter
clearCache

mysql -h mysql -u root -proot -e "DROP DATABASE IF EXISTS $SHOPWARE_PROJECT"
mysql -h mysql -u root -proot -e "CREATE DATABASE $SHOPWARE_PROJECT"
cd "/var/www/html/${SHOPWARE_PROJECT}"

echo "APP_ENV=docker
APP_SECRET=8583a6ff63c5894a3195331701749943
APP_URL=http://${SHOPWARE_PROJECT}.platform.localhost
MAILER_URL=null://localhost

DATABASE_URL=mysql://root:root@mysql:3306/${SHOPWARE_PROJECT}

COMPOSER_HOME=/tmp/composer-tmp-${SHOPWARE_PROJECT}" > .env

export PROJECT_ROOT=$SHOPWARE_FOLDER

composer install -o

php dev-ops/generate_ssl.php

mysql -h mysql -u root -proot $SHOPWARE_PROJECT < vendor/shopware/platform/src/Core/schema.sql 
bin/console database:migrate --all Shopware\\
bin/console database:migrate-destructive --all Shopware\\
bin/console administration:dump:bundles
bin/console scheduled-task:register
bin/console user:create admin --password=shopware
bin/console sales-channel:create:storefront --url="http://${SHOPWARE_PROJECT}.platform.localhost"


if [[ ! "$@" == *"--without-demo-data" ]]; then
    APP_ENV=prod bin/console framework:demodata
    bin/console dbal:refresh:index
fi

if [[ ! "$@" == *"--without-building" ]]; then
    npm --prefix vendor/shopware/platform/src/Administration/Resources/administration/ install
    npm run --prefix vendor/shopware/platform/src/Administration/Resources/administration/ build

    npm --prefix vendor/shopware/platform/src/Storefront/Resources/ install
    npm --prefix vendor/shopware/platform/src/Storefront/Resources/ run production

    php bin/console assets:install
fi