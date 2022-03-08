#!/usr/bin/env bash

checkParameter
clearCache

cd "${SHOPWARE_FOLDER}" || exit 1
export PROJECT_ROOT="${SHOPWARE_FOLDER}"

setup_node_version

PLATFORM_PATH=$(platform_component Storefront)

bin/console bundle:dump

npm --prefix "${PLATFORM_PATH}/Resources/app/storefront/" run production

bin/console assets:install
bin/console theme:compile
