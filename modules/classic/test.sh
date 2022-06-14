#!/usr/bin/env bash

mysqlHost="mysql"
checkParameter

cd /var/www/html/"${SHOPWARE_PROJECT}" || exit 1

mysql -h "${mysqlHost}" -u root -p"${MYSQL_ROOT_PASSWORD}"  "$SHOPWARE_PROJECT" < "build_backup.sql"

vendor/bin/phpunit tests/Unit/ --config tests/phpunit_unit.xml.dist "${@:3}"

vendor/bin/phpunit tests/Functional/ --config tests/phpunit.xml.dist --exclude-group=elasticSearch "${@:3}"

fixHooks
