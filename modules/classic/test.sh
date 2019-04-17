#!/usr/bin/env bash

checkParameter
clearCache

cd /var/www/html/${SHOPWARE_PROJECT}
ant -Dapp.host=$SHOPWARE_PROJECT.dev.localhost -Ddb.host=mysql -Ddb.user=root -Ddb.password=root -Ddb.name=$SHOPWARE_PROJECT -f /var/www/html/$SHOPWARE_PROJECT/build/build.xml build-unit

php ./vendor/bin/phpunit -c tests ${@:3}

fixHooks