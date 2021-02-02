#!/usr/bin/env bash

checkParameter
cd "/var/www/html/${SHOPWARE_PROJECT}" || exit 1

export USE_SSL_DEFAULT=false
URL=$(get_url "$SHOPWARE_PROJECT")
export PROJECT_ROOT=$SHOPWARE_FOLDER

bin/console bundle:dump

export PORT=8181
export HOST=0.0.0.0
export ESLINT_DISABLE=true
export ENV_FILE=$SHOPWARE_FOLDER/.env
export APP_URL=$URL

PLATFORM_PATH=$(platform_component Administration)

if [[ -e $PLATFORM_PATH/Resources/app/administration/build/build.js ]]; then
  npm run --prefix "$PLATFORM_PATH"/Resources/app/administration/ dev -- "$URL"
else
  npm run --prefix "$PLATFORM_PATH"/Resources/app/administration/ dev
fi
