#!/usr/bin/env bash

checkParameter
clearCache

mysql -h mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS $SHOPWARE_PROJECT"

cd /var/www/html/$SHOPWARE_PROJECT

URL=$(get_url $SHOPWARE_PROJECT)

touch recovery/install/data/install.lock

echo "<?php
return [
    'db' => [
        'username' => 'root',
        'password' => '${MYSQL_ROOT_PASSWORD}',
        'dbname' => '${SHOPWARE_PROJECT}',
        'host' => 'mysql',
        'port' => '3306'
    ]
];" > config.php

composer install

./bin/console sw:database:setup --steps=drop,create,import

if [[ ! "$@" == *"--without-demo-data" ]]; then
    ./bin/console sw:database:setup --steps=importDemodata
fi

clearCache

./bin/console sw:database:setup --steps=setupShop --shop-url=$URL
./bin/console sw:snippets:to:db --include-plugins
./bin/console sw:theme:initialize
./bin/console sw:firstrunwizard:disable
./bin/console sw:admin:create --name="Demo" --email="demo@demo.de" --username="demo" --password="demo" --locale=de_DE -n

fixHooks

if [[ ! "$@" == *"--without-config-patch" ]]; then
    php ${DIR}/modules/classic/fix-config.php "$SHOPWARE_FOLDER/config.php"
fi