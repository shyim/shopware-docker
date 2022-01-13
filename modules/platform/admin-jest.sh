#!/usr/bin/env bash

checkParameter

cd "${SHOPWARE_FOLDER}" || exit 1
export PROJECT_ROOT="/var/www/html/${SHOPWARE_PROJECT}"
export ENV_FILE="${PROJECT_ROOT}/.env"
ADMINISTRATION_PATH="${PROJECT_ROOT}/$(platform_component Administration)"

npm run --prefix "${ADMINISTRATION_PATH}Resources/app/administration" unit-watch