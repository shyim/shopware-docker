#!/usr/bin/env bash

checkParameter
clearCache
mysql -h mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS $SHOPWARE_PROJECT"
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

composer install -o
php psh.phar install