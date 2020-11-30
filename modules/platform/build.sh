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
BLUE_GREEN_DEPLOYMENT=1
MAILER_URL=\"sendmail://localhost?command=ssmtp -t\"
INSTANCE_ID=${INSTANCE_ID}
DATABASE_URL=mysql://root:${MYSQL_ROOT_PASSWORD}@mysql:3306/${SHOPWARE_PROJECT}
SHOPWARE_ES_HOSTS=elastic
SHOPWARE_ES_ENABLED=0
SHOPWARE_ES_INDEXING_ENABLED=0
SHOPWARE_ES_INDEX_PREFIX=test_
COMPOSER_HOME=/tmp/composer-tmp-${SECRET}
SHOPWARE_HTTP_CACHE_ENABLED=0
SHOPWARE_HTTP_DEFAULT_TTL=7200" > .env

echo "const:
  APP_ENV: dev
  APP_URL: \"${URL}\"
  DB_USER: root
  DB_PASSWORD: \"${MYSQL_ROOT_PASSWORD}\"
  DB_HOST: mysql
  DB_PORT: 3306
  DB_NAME: \"${SHOPWARE_PROJECT}\"
  APP_MAILER_URL: \"smtp://smtp:25\"" > .psh.yaml.override

export PROJECT_ROOT=$SHOPWARE_FOLDER

composer install -o

PLATFORM_PATH=$(platform_component Core)

php dev-ops/generate_ssl.php
echo ''

mysql -h mysql -u root -proot "$SHOPWARE_PROJECT" < $PLATFORM_PATH/schema.sql

if [[ -d $PLATFORM_PATH/Framework/App ]]; then
    bin/console database:migrate --all
    bin/console database:migrate-destructive --all
else
    bin/console database:migrate --all Shopware\\

    if [[ $? == 0 ]]; then
        bin/console database:migrate-destructive --all Shopware\\
    else
        bin/console database:migrate --all
        bin/console database:migrate-destructive --all
    fi
fi

bin/console bundle:dump
bin/console scheduled-task:register
bin/console user:create admin --password=shopware
bin/console sales-channel:create:storefront --url="$URL"


if [[ ! "$@" == *"--without-demo-data"* ]]; then
    APP_ENV=prod bin/console framework:demodata
    bin/console dal:refresh:index
fi

if [[ ! "$@" == *"--without-building"* ]]; then
    npm clean-install --prefix vendor/shopware/platform/src/Administration/Resources
    npm run --prefix vendor/shopware/platform/src/Administration/Resources lerna -- bootstrap
    npm run --prefix vendor/shopware/platform/src/Administration/Resources/app/administration/ build

    npm --prefix vendor/shopware/platform/src/Storefront/Resources/app/storefront/ clean-install
    node vendor/shopware/platform/src/Storefront/Resources/app/storefront/copy-to-vendor.js
    npm --prefix vendor/shopware/platform/src/Storefront/Resources/app/storefront/ run production
    
    php bin/console assets:install
fi

bin/console theme:refresh
bin/console theme:change Storefront --all
