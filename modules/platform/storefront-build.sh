#!/usr/bin/env bash

checkParameter
clearCache

export PROJECT_ROOT="/var/www/html/$SHOPWARE_PROJECT"
cd "${PROJECT_ROOT}" || exit 1

PLATFORM_PATH=$(platform_component Storefront)

bin/console bundle:dump

npm --prefix "${PLATFORM_PATH}/Resources/app/storefront/" run production

bin/console assets:install
bin/console theme:compile
