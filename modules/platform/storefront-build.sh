#!/usr/bin/env bash

checkParameter
clearCache

export PROJECT_ROOT="/var/www/html/$SHOPWARE_PROJECT/"
cd ${PROJECT_ROOT}

bin/console bundle:dump
npm --prefix vendor/shopware/platform/src/Storefront/Resources/app/storefront/ run production

bin/console theme:compile
bin/console assets:install
