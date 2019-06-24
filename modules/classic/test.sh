#!/usr/bin/env bash

checkParameter

cd /var/www/html/${SHOPWARE_PROJECT}

$0 build $SHOPWARE_PROJECT



php ./vendor/bin/phpunit -c tests --exclude-group=elasticSearch ${@:3}

fixHooks
