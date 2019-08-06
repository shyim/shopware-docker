#!/usr/bin/env bash

checkParameter

cd /var/www/html/${SHOPWARE_PROJECT}

vendor/bin/phpunit tests/Unit/ --config tests/phpunit_unit.xml.dist ${@:3}