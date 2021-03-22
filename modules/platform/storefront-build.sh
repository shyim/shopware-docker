#!/usr/bin/env bash

checkParameter
clearCache

export PROJECT_ROOT="/var/www/html/$SHOPWARE_PROJECT/"
cd "${PROJECT_ROOT}" || exit 1

bin/console bundle:dump

if [[ -e vendor/shopware/platform ]]; then
  npm --prefix vendor/shopware/platform/src/Storefront/Resources/app/storefront/ run production
else
  npm --prefix vendor/shopware/storefront/Resources/app/storefront/ run production
fi

bin/console assets:install
bin/console theme:compile
