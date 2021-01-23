#!/usr/bin/env bash

checkParameter
clearCache

mysqlHost="mysql"
patchConfig=1
generateDemoData=1

shift 2

while (( $# )); do
    case $1 in
        --mysql-host)
            shift
            mysqlHost=$1
        ;;
        --without-config-patch)
            patchConfig=0
        ;;
        --without-demo-data)
            generateDemoData=0
        ;;
    esac
    shift
done

mysql -h $mysqlHost -u root -p${MYSQL_ROOT_PASSWORD} -e "DROP DATABASE IF EXISTS \`$SHOPWARE_PROJECT\`"
mysql -h $mysqlHost -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE \`$SHOPWARE_PROJECT\`"

cd /var/www/html/$SHOPWARE_PROJECT

URL=$(get_url $SHOPWARE_PROJECT)

touch recovery/install/data/install.lock

echo "<?php
return [
    'db' => [
        'username' => 'root',
        'password' => '${MYSQL_ROOT_PASSWORD}',
        'dbname' => '${SHOPWARE_PROJECT}',
        'host' => '${mysqlHost}',
        'port' => '3306'
    ]
];" > config.php

composer install

mysql -h $mysqlHost -u root -p${MYSQL_ROOT_PASSWORD} $SHOPWARE_PROJECT < _sql/install/latest.sql

if [[ -f build/ApplyDeltas.php ]]; then
    php build/ApplyDeltas.php --username="root" --password="${MYSQL_ROOT_PASSWORD}" --host="$mysqlHost" --dbname="$SHOPWARE_PROJECT" --mode=install
else
    ./bin/console sw:migration:migrate --mode=install
fi

if [[ $generateDemoData == 1 ]]; then
    mysql -h mysql -u root -p${MYSQL_ROOT_PASSWORD} $SHOPWARE_PROJECT < _sql/demo/latest.sql
fi

clearCache

php ./bin/console sw:generate:attributes

PROTO="$(echo $URL | grep :// | sed -e's,^\(.*://\).*,\1,g')"

HOST=$(echo $URL | awk -F[/:] '{print $4}')
mysql -h mysql -u root -p${MYSQL_ROOT_PASSWORD} $SHOPWARE_PROJECT -e "UPDATE s_core_shops SET host = '$HOST', base_path = '' WHERE main_id IS NULL"

if [[ $PROTO == 'https://' ]]; then
    mysql -h mysql -u root -p${MYSQL_ROOT_PASSWORD} $SHOPWARE_PROJECT -e "UPDATE s_core_shops SET secure = 1 WHERE main_id IS NULL"
fi

./bin/console sw:snippets:to:db --include-plugins
./bin/console sw:theme:initialize
./bin/console sw:firstrunwizard:disable
./bin/console sw:admin:create --name="Demo" --email="demo@demo.de" --username="demo" --password="demo" --locale=de_DE -n

fixHooks

if [[ $patchConfig == 1 ]]; then
    php ${DIR}/modules/classic/fix-config.php "$SHOPWARE_FOLDER/config.php"
fi