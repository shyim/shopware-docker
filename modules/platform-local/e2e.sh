#!/usr/bin/env bash

SHOPWARE_PROJECT=$2
MODULE=$3
export USE_SSL_DEFAULT=false
URL=$(get_url "$SHOPWARE_PROJECT")

if [[ -z $MODULE ]]; then
  MODULE="Administration"
fi

cd "${CODE_DIRECTORY}/${SHOPWARE_PROJECT}" || exit

E2E_DIR="vendor/shopware/platform/src/${MODULE}/Resources/app/${MODULE,}/test/e2e"
E2E_PATH="/var/www/html/${SHOPWARE_PROJECT}/${E2E_DIR}"

if [[ ! -d "${E2E_DIR}/node_modules" ]]; then
  compose exec cli bash npm install --prefix ${E2E_PATH}
fi

xhost +si:localuser:root

compose run --rm -w "${E2E_PATH}" --entrypoint=cypress cypress open --project . --config baseUrl="$URL"
