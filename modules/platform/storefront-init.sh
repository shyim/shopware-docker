#!/usr/bin/env bash

checkParameter
clearCache

export PROJECT_ROOT="/var/www/html/$SHOPWARE_PROJECT/"
cd ${PROJECT_ROOT}

bin/console bundle:dump

if [[ -e vendor/shopware/platform ]]; then
    npm --prefix vendor/shopware/platform/src/Storefront/Resources/app/storefront/ clean-install
else
    npm --prefix vendor/shopware/storefront/Resources/app/storefront/ clean-install
fi