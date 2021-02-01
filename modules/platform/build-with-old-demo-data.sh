#!/usr/bin/env bash

checkParameter
clearCache

mysqlHost="mysql"

shift 2

while (( $# )); do
    case $1 in
        --mysql-host)
            shift
            mysqlHost=$1
        ;;
    esac
    shift
done

mysql -h $mysqlHost -u root -p$MYSQL_ROOT_PASSWORD -e "DROP DATABASE IF EXISTS \`$SHOPWARE_PROJECT\`"
mysql -h $mysqlHost -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE \`$SHOPWARE_PROJECT\`"
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
DATABASE_URL=mysql://root:${MYSQL_ROOT_PASSWORD}@${mysqlHost}:3306/${SHOPWARE_PROJECT}
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
  DB_HOST: ${mysqlHost}
  DB_PORT: 3306
  DB_NAME: \"${SHOPWARE_PROJECT}\"
  APP_MAILER_URL: \"smtp://smtp:25\"" > .psh.yaml.override


export PROJECT_ROOT=$SHOPWARE_FOLDER

composer install -o
php dev-ops/generate_ssl.php
echo ''

SNAP_DIR="/var/www/html/snapshots"

if [[ ! -d "$SNAP_DIR" ]]; then
	mkdir "$SNAP_DIR"
fi

if [[ ! -f "${SNAP_DIR}/_sw6_demo_images.zip" ]]; then
    wget -O ${SNAP_DIR}/_sw6_demo_images.zip https://cdn.shyim.de/sw6_demo_images.zip
fi

if [[ ! -f "${SNAP_DIR}/_sw6_demo_images.sql" ]]; then
    wget -O ${SNAP_DIR}/_sw6_demo_images.sql https://cdn.shyim.de/sw6_demo_images.sql
fi


mysql -h $mysqlHost -u root -proot "$SHOPWARE_PROJECT" < ${SNAP_DIR}/_sw6_demo_images.sql
unzip -o ${SNAP_DIR}/_sw6_demo_images.zip -d ${SHOPWARE_FOLDER}/

mysql -h $mysqlHost -uroot -proot "$SHOPWARE_PROJECT" -e "UPDATE sales_channel_domain SET url = \"${URL}/en\" WHERE id = 0xB420C81E6B324DD89C316BDDC25E8BF2"
mysql -h $mysqlHost -uroot -proot "$SHOPWARE_PROJECT" -e "UPDATE sales_channel_domain SET url = \"${URL}\" WHERE id = 0xC823787968154569B8F8F160F35BA1F6"

bin/console database:migrate --all
bin/console database:migrate-destructive --all
bin/console theme:compile
bin/console assets:install