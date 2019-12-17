#!/usr/bin/env bash

checkParameter
cd "/var/www/html/${SHOPWARE_PROJECT}"

URL=$(get_url $SHOPWARE_PROJECT)
export PROJECT_ROOT=$SHOPWARE_FOLDER

bin/console bundle:dump
PORT=8181 HOST=0.0.0.0 ESLINT_DISABLE=true ENV_FILE=$SHOPWARE_FOLDER/.env npm run --prefix vendor/shopware/platform/src/Administration/Resources/app/administration/ dev -- $URL