#!/usr/bin/env bash

checkParameter
clearCache

PROJECT_ROOT="/var/www/html/$SHOPWARE_PROJECT/"
URL=$(get_url $SHOPWARE_PROJECT)

cd ${PROJECT_ROOT}

bin/console bundle:dump
export APP_URL=$URL
export PROJECT_ROOT=$PROJECT_ROOT

if [[ -e vendor/shopware/platform ]]; then
    npm --prefix vendor/shopware/platform/src/Storefront/Resources/app/storefront/ install
    npm --prefix vendor/shopware/platform/src/Storefront/Resources/app/storefront/ run watch
else
    npm --prefix vendor/shopware/storefront/Resources/app/storefront/ install
    npm --prefix vendor/shopware/storefront/Resources/app/storefront/ run watch
fi