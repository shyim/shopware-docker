#!/usr/bin/env bash

checkParameter
clearCache
mysql -h mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS $SHOPWARE_PROJECT"
cd "/var/www/html/${SHOPWARE_PROJECT}"

echo "SHOPWARE_VERSION_TEXT=\"$SHOPWARE_PROJECT (local docker)\"" >> "$SHOPWARE_FOLDER/.env"
echo "SHOPWARE_REVISION=\"`git rev-parse HEAD`\"" >> "$SHOPWARE_FOLDER/.env"
echo "DATABASE_URL=\"mysql://root:root@mysql:3306/$SHOPWARE_PROJECT\"" >> "$SHOPWARE_FOLDER/.env"
echo 'ADMIN_EMAIL="demo@demo.com"' >> "$SHOPWARE_FOLDER/.env"
echo 'ADMIN_NAME="Don Joe"' >> "$SHOPWARE_FOLDER/.env"
echo 'ADMIN_USERNAME="demo"' >> "$SHOPWARE_FOLDER/.env"
echo 'ADMIN_PASSWORD="demo"' >> "$SHOPWARE_FOLDER/.env"
echo "SHOP_URL=\"http://$SHOPWARE_PROJECT.dev.localhost\"" >> "$SHOPWARE_FOLDER/.env"
echo 'IMPORT_DEMODATA=y' >> "$SHOPWARE_FOLDER/.env"

bash -c "composer install"

NEW_INSTALLER_PATH="/var/www/html/${SHOPWARE_PROJECT}/app/bin/install.sh"
OLD_INSTALLER_PATH="/var/www/html/${SHOPWARE_PROJECT}/app/install.sh"
bash -c "if [ -x \"$NEW_INSTALLER_PATH\" ]; then bash \"$NEW_INSTALLER_PATH\"; else bash \"$OLD_INSTALLER_PATH\"; fi"
