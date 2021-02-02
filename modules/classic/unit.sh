#!/usr/bin/env bash

checkParameter

cd /var/www/html/"${SHOPWARE_PROJECT}" || exit 1

vendor/bin/phpunit tests/Unit/ --config tests/phpunit_unit.xml.dist "${@:3}"
