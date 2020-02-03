#!/usr/bin/env bash

checkParameter
clearCache

PROJECT_ROOT="/var/www/html/$SHOPWARE_PROJECT/"
URL=$(get_url $SHOPWARE_PROJECT)

cd ${PROJECT_ROOT}

bin/console bundle:dump
APP_URL=$URL PROJECT_ROOT=$PROJECT_ROOT npm --prefix vendor/shopware/platform/src/Storefront/Resources/app/storefront/ run watch
