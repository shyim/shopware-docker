#!/usr/bin/env bash

checkParameter
clearCache

export PROJECT_ROOT="/var/www/html/$SHOPWARE_PROJECT/"
cd "${PROJECT_ROOT}" || exit 1

STOREFRONT_PATH=$(platform_component Storefront)
npm --prefix "$STOREFRONT_PATH/Resources/app/storefront/" clean-install
