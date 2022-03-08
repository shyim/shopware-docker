#!/usr/bin/env bash

checkParameter
clearCache

cd "${SHOPWARE_FOLDER}" || exit 1
export PROJECT_ROOT="${SHOPWARE_FOLDER}"

setup_node_version

STOREFRONT_PATH=$(platform_component Storefront)
npm --prefix "$STOREFRONT_PATH/Resources/app/storefront/" clean-install
