#!/usr/bin/env bash

checkParameter
clearCache

mysql -h mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS $SHOPWARE_PROJECT"

ant -Dapp.host=$SHOPWARE_PROJECT.dev.localhost -Ddb.host=mysql -Ddb.user=root -Ddb.password=root -Ddb.name=$SHOPWARE_PROJECT -f /var/www/html/$SHOPWARE_PROJECT/build/build.xml build-unit
fixHooks

php ${DIR}/modules/classic/fix-config.php "$SHOPWARE_FOLDER/config.php" $3