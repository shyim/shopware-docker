#!/usr/bin/env bash

checkParameter
clearCache

PROJECT_ROOT="/var/www/html/$SHOPWARE_PROJECT/"
cd ${PROJECT_ROOT}

bin/console bundle:dump
PROJECT_ROOT=$PROJECT_ROOT npm --prefix vendor/shopware/platform/src/Storefront/Resources/ run production

bin/console theme:compile
bin/console assets:install
