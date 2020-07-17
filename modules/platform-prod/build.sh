#!/usr/bin/env bash

checkParameter
clearCache

mysql -h mysql -u root -proot -e "DROP DATABASE IF EXISTS \`$SHOPWARE_PROJECT\`"
mysql -h mysql -u root -proot -e "CREATE DATABASE \`$SHOPWARE_PROJECT\`"
cd "/var/www/html/${SHOPWARE_PROJECT}"
URL=$(get_url $SHOPWARE_PROJECT)
SECRET=$(openssl rand -hex 32)
INSTANCE_ID=$(openssl rand -hex 32)

echo "APP_ENV=dev
APP_SECRET=${SECRET}
APP_URL=${URL}
MAILER_URL=smtp://smtp:25
INSTANCE_ID=${INSTANCE_ID}
DATABASE_URL=mysql://root:${MYSQL_ROOT_PASSWORD}@mysql:3306/${SHOPWARE_PROJECT}
SHOPWARE_ES_HOSTS=elastic
SHOPWARE_ES_ENABLED=0
SHOPWARE_ES_INDEXING_ENABLED=0
SHOPWARE_ES_INDEX_PREFIX=test_
COMPOSER_HOME=/tmp/composer-tmp-${SECRET}
SHOPWARE_HTTP_CACHE_ENABLED=0
SHOPWARE_HTTP_DEFAULT_TTL=7200" > .env

export PROJECT_ROOT=$SHOPWARE_FOLDER

composer install

bin/console system:install --create-database --basic-setup --force
bin/console system:generate-jwt-secret