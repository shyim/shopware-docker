#!/usr/bin/env bash

checkParameter

cd "${SHOPWARE_FOLDER}" || exit 1
export PROJECT_ROOT="/var/www/html/${SHOPWARE_PROJECT}"
export ENV_FILE="${PROJECT_ROOT}/.env"
ADMINISTRATION_PATH="${PROJECT_ROOT}/$(platform_component Administration)"

bin/console framework:schema -s 'entity-schema' "${ADMINISTRATION_PATH}Resources/app/administration/test/_mocks_/entity-schema.json"

setup_node_version

npm run --prefix "${ADMINISTRATION_PATH}Resources/app/administration" unit-watch