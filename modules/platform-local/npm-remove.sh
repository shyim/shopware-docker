#!/usr/bin/env bash

LOCAL_PROJECT_ROOT="${CODE_DIRECTORY}/${SHOPWARE_PROJECT}"
cd "$LOCAL_PROJECT_ROOT" || exit
STOREFRONT_PATH=$(platform_component Storefront)
ADMINISTRATION_PATH=$(platform_component Administration)

if [[ -e "$STOREFRONT_PATH/Resources/app/storefront/node_modules" ]]; then
    rm -rf "$STOREFRONT_PATH/Resources/app/storefront/node_modules"
    echo "Deleted Storefront node_modules"
fi

if [[ -e "$ADMINISTRATION_PATH/Resources/app/administration/node_modules" ]]; then
    rm -rf "$ADMINISTRATION_PATH/Resources/app/administration/node_modules"
    echo "Deleted Administration node_modules"
fi