#!/usr/bin/env bash

checkParameter
clearCache

mysql -h mysql -u root -proot -e "DROP DATABASE IF EXISTS $SHOPWARE_PROJECT"
mysql -h mysql -u root -proot -e "CREATE DATABASE $SHOPWARE_PROJECT"
cd "/var/www/html/${SHOPWARE_PROJECT}"

echo "const:" > "$SHOPWARE_FOLDER/.psh.yaml.override"
echo "  APP_ENV: dev" >> "$SHOPWARE_FOLDER/.psh.yaml.override"
echo "  APP_URL: http://$SHOPWARE_PROJECT.platform.localhost" >> "$SHOPWARE_FOLDER/.psh.yaml.override"
echo "  DB_HOST: mysql" >> "$SHOPWARE_FOLDER/.psh.yaml.override"
echo "  DB_PORT: 3306" >> "$SHOPWARE_FOLDER/.psh.yaml.override"
echo "  DB_NAME: $SHOPWARE_PROJECT" >> "$SHOPWARE_FOLDER/.psh.yaml.override"
echo "  DB_USER: root" >> "$SHOPWARE_FOLDER/.psh.yaml.override"
echo "  DB_PASSWORD: root" >> "$SHOPWARE_FOLDER/.psh.yaml.override"
echo "  DEVPORT: 8181" >> "$SHOPWARE_FOLDER/.psh.yaml.override"

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
    APP_ENV=dev bin/console framework:demodata
    bin/console dbal:refresh:index
fi

if [[ ! "$@" == *"--without-building" ]]; then
    npm --prefix vendor/shopware/platform/src/Administration/Resources/administration/ install
    npm run --prefix vendor/shopware/platform/src/Administration/Resources/administration/ build

    npm --prefix vendor/shopware/platform/src/Storefront/Resources/ install
    npm --prefix vendor/shopware/platform/src/Storefront/Resources/ run production

    php bin/console assets:install
fi