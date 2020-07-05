#!/usr/bin/env bash

checkParameter
cd "/var/www/html/${SHOPWARE_PROJECT}"

export USE_SSL_DEFAULT=false
URL=$(get_url $SHOPWARE_PROJECT)
export PROJECT_ROOT=$SHOPWARE_FOLDER

bin/console bundle:dump

export PORT=8181
export HOST=0.0.0.0
export ESLINT_DISABLE=true
export ENV_FILE=$SHOPWARE_FOLDER/.env
export APP_URL=$URL

if [[ -e vendor/shopware/platform ]]; then
    npm run --prefix vendor/shopware/platform/src/Administration/Resources/app/administration/ dev -- $URL
else
    npm run --prefix vendor/shopware/administration/Resources/app/administration/ dev -- $URL
fi