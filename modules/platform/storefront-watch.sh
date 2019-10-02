#!/usr/bin/env bash

checkParameter
clearCache

PROJECT_ROOT="/var/www/html/$SHOPWARE_PROJECT/"
PROJECT_URL="$SHOPWARE_PROJECT.platform.localhost"

cd ${PROJECT_ROOT}

bin/console bundle:dump
APP_URL=$PROJECT_URL PROJECT_ROOT=$PROJECT_ROOT npm --prefix vendor/shopware/platform/src/Storefront/Resources/ run watch
