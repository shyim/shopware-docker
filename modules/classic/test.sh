#!/usr/bin/env bash

checkParameter

cd /var/www/html/"${SHOPWARE_PROJECT}" || exit 1

$0 build "$SHOPWARE_PROJECT"

vendor/bin/phpunit tests/Unit/ --config tests/phpunit_unit.xml.dist "${@:3}"

vendor/bin/phpunit tests/Functional/ --config tests/phpunit.xml.dist --exclude-group=elasticSearch "${@:3}"

fixHooks
