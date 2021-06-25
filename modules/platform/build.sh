#!/usr/bin/env bash

checkParameter
clearCache

generateDemoData=1
buildJS=1
mysqlHost="mysql"

shift 2

while (($#)); do
  case $1 in
  --mysql-host)
    shift
    mysqlHost=$1
    ;;
  --without-demo-data)
    generateDemoData=0
    ;;
  --without-building)
    buildJS=0
    ;;
  esac
  shift
done

mysql -h "$mysqlHost" -u root -p"$MYSQL_ROOT_PASSWORD" -e "DROP DATABASE IF EXISTS \`$SHOPWARE_PROJECT\`"
mysql -h "$mysqlHost" -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE \`$SHOPWARE_PROJECT\`"
cd "/var/www/html/${SHOPWARE_PROJECT}" || exit 1
URL=$(get_url "$SHOPWARE_PROJECT")
SECRET=$(openssl rand -hex 32)
INSTANCE_ID=$(openssl rand -hex 32)
MAILER_URL="smtp://smtp:1025?encryption=&auth_mode="

composer install -o

if [[ ! -e "vendor/swiftmailer/" ]]; then
  MAILER_URL="smtp://smtp:1025"
fi

echo "APP_ENV=dev
APP_SECRET=${SECRET}
APP_URL=${URL}
BLUE_GREEN_DEPLOYMENT=1
MAILER_URL=\"${MAILER_URL}\"
INSTANCE_ID=${INSTANCE_ID}
DATABASE_URL=mysql://root:${MYSQL_ROOT_PASSWORD}@${mysqlHost}:3306/${SHOPWARE_PROJECT}
SHOPWARE_ES_HOSTS=elastic
SHOPWARE_ES_ENABLED=0
SHOPWARE_ES_INDEXING_ENABLED=0
SHOPWARE_ES_INDEX_PREFIX=${SHOPWARE_PROJECT}
COMPOSER_HOME=/tmp/composer-tmp-${SECRET}
SHOPWARE_HTTP_CACHE_ENABLED=0
SHOPWARE_HTTP_DEFAULT_TTL=7200" > .env

if [[ -e build/feature.env ]]; then
  cat build/feature.env >> .env
fi

echo "const:
  APP_ENV: dev
  APP_URL: \"${URL}\"
  DB_USER: root
  DB_PASSWORD: \"${MYSQL_ROOT_PASSWORD}\"
  DB_HOST: ${mysqlHost}
  DB_PORT: 3306
  DB_NAME: \"${SHOPWARE_PROJECT}\"
  APP_MAILER_URL: \"${MAILER_URL}\"" >.psh.yaml.override

export PROJECT_ROOT=$SHOPWARE_FOLDER

CORE_PATH=$(platform_component Core)
ADMINISTRATION_PATH=$(platform_component Administration)
STOREFRONT_PATH=$(platform_component Storefront)

php dev-ops/generate_ssl.php
echo ''

mysql -h "$mysqlHost" -u root -proot "$SHOPWARE_PROJECT" <"$CORE_PATH"/schema.sql

if [[ -d $CORE_PATH/Framework/App ]]; then
  bin/console database:migrate --all
  bin/console database:migrate-destructive --all
else

  if ! bin/console database:migrate --all Shopware\\; then
    bin/console database:migrate --all
    bin/console database:migrate-destructive --all
  else
    bin/console database:migrate-destructive --all Shopware\\
  fi
fi

bin/console bundle:dump
bin/console feature:dump || true
bin/console scheduled-task:register
bin/console user:create admin --password=shopware
bin/console sales-channel:create:storefront --url="$URL"

if [[ $generateDemoData == 1 ]]; then
  APP_ENV=prod bin/console framework:demodata
  APP_ENV=prod bin/console dal:refresh:index
fi

if [[ $buildJS == 1 ]]; then
  if [[ -e "$ADMINISTRATION_PATH/Resources/lerna.json" ]]; then
    npm clean-install --prefix "$ADMINISTRATION_PATH/Resources"
    npm run --prefix "$ADMINISTRATION_PATH/Resources" lerna -- bootstrap
  else
    npm clean-install --prefix "$ADMINISTRATION_PATH/Resources/app/administration/"
  fi

  npm run --prefix "$ADMINISTRATION_PATH/Resources/app/administration/" build

  npm --prefix "$STOREFRONT_PATH/Resources/app/storefront/" clean-install
  node "$STOREFRONT_PATH/Resources/app/storefront/copy-to-vendor.js"
  npm --prefix "$STOREFRONT_PATH/Resources/app/storefront/" run production

  php bin/console assets:install
fi

bin/console theme:refresh
bin/console theme:change Storefront --all
