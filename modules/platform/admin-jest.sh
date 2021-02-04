#!/usr/bin/env bash

checkParameter

cd "/var/www/html/${SHOPWARE_PROJECT}" || exit 1
export PROJECT_ROOT="/var/www/html/${SHOPWARE_PROJECT}"
export ENV_FILE="${PROJECT_ROOT}/.env"
PLATFORM_PATH=$(platform_component Administration)
export ADMIN_PATH="/var/www/html/sw6/${PLATFORM_PATH}Resources/app/administration/"

npm run --prefix "$ADMIN_PATH" unit-watch
