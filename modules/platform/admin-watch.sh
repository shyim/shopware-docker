#!/usr/bin/env bash

checkParameter
cd "/var/www/html/${SHOPWARE_PROJECT}"

URL="http://${SHOPWARE_PROJECT}.platform.localhost"
export PROJECT_ROOT=$SHOPWARE_FOLDER

bin/console administration:dump:bundles
APP_ENV=docker PORT=8181 HOST=0.0.0.0 ESLINT_DISABLE=true ENV_FILE=$SHOPWARE_FOLDER/.env npm run --prefix vendor/shopware/platform/src/Administration/Resources/administration/ dev -- $URL