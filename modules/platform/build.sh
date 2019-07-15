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
INSTANCE_ID=test
DATABASE_URL=mysql://root:root@mysql:3306/${SHOPWARE_PROJECT}
SHOPWARE_SES_HOSTS=elastic
SHOPWARE_SES_ENABLED=0
SHOPWARE_SES_INDEXING_ENABLED=0
SHOPWARE_SES_INDEX_PREFIX=test_
COMPOSER_HOME=/tmp/composer-tmp-${SHOPWARE_PROJECT}" > .env

export PROJECT_ROOT=$SHOPWARE_FOLDER

composer install -o

php dev-ops/generate_ssl.php

mysql -h mysql -u root -proot $SHOPWARE_PROJECT < vendor/shopware/platform/src/Core/schema.sql 
bin/console database:migrate --all Shopware\\
bin/console database:migrate-destructive --all Shopware\\
bin/console bundle:dump
bin/console scheduled-task:register
bin/console user:create admin --password=shopware
bin/console sales-channel:create:storefront --url="http://${SHOPWARE_PROJECT}.platform.localhost"


if [[ ! "$@" == *"--without-demo-data" ]]; then
    APP_ENV=prod bin/console framework:demodata
    bin/console dal:refresh:index
fi

if [[ ! "$@" == *"--without-building" ]]; then
    npm clean-install --prefix vendor/shopware/platform/src/Administration/Resources
    npm run --prefix vendor/shopware/platform/src/Administration/Resources lerna -- bootstrap
    npm run --prefix vendor/shopware/platform/src/Administration/Resources/administration/ build

    npm --prefix vendor/shopware/platform/src/Storefront/Resources/ install
    npm --prefix vendor/shopware/platform/src/Storefront/Resources/ run production

    php bin/console assets:install
fi
