#!/usr/bin/env bash

checkParameter
clearCache

mysqlHost="mysql"

shift 2

while (($#)); do
  case $1 in
  --mysql-host)
    shift
    mysqlHost=$1
    ;;
  esac
  shift
done

mysql -h "$mysqlHost" -u root -proot -e "DROP DATABASE IF EXISTS \`$SHOPWARE_PROJECT\`"
mysql -h "$mysqlHost" -u root -proot -e "CREATE DATABASE \`$SHOPWARE_PROJECT\`"
cd "/var/www/html/${SHOPWARE_PROJECT}" || exit
URL=$(get_url "$SHOPWARE_PROJECT")
SECRET=$(openssl rand -hex 32)
INSTANCE_ID=$(openssl rand -hex 32)

echo "APP_ENV=dev
APP_SECRET=${SECRET}
APP_URL=${URL}
BLUE_GREEN_DEPLOYMENT=1
MAILER_URL=\"sendmail://localhost?command=sendmail -t\"
INSTANCE_ID=${INSTANCE_ID}
DATABASE_URL=mysql://root:${MYSQL_ROOT_PASSWORD}@${mysqlHost}:3306/${SHOPWARE_PROJECT}
SHOPWARE_ES_HOSTS=elastic
SHOPWARE_ES_ENABLED=0
SHOPWARE_ES_INDEXING_ENABLED=0
SHOPWARE_ES_INDEX_PREFIX=test_
COMPOSER_HOME=/tmp/composer-tmp-${SECRET}
SHOPWARE_HTTP_CACHE_ENABLED=0
SHOPWARE_HTTP_DEFAULT_TTL=7200" >.env

export PROJECT_ROOT=$SHOPWARE_FOLDER

composer install

bin/console system:install --create-database --basic-setup --force

rm config/jwt/private.pem || true
rm config/jwt/public.pem || true
bin/console system:generate-jwt-secret
