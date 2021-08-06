#!/usr/bin/env bash

SHOPWARE_PROJECT=$2
APP_URL=$(get_url "$SHOPWARE_PROJECT")
export APP_URL="${APP_URL}"
HOST=$(get_host "$SHOPWARE_PROJECT")
export STOREFRONT_PROXY_PORT=80
export PROJECT_ROOT="/var/www/html/${SHOPWARE_PROJECT}"
export ESLINT_DISABLE=false

compose exec -w "/var/www/html/${SHOPWARE_PROJECT}" cli php bin/console theme:dump

docker run \
  --rm \
  --network shopware-docker_default \
  -v "${CODE_DIRECTORY}/${SHOPWARE_PROJECT}:/var/www/html/${SHOPWARE_PROJECT}" \
  -w "/var/www/html/${SHOPWARE_PROJECT}" \
  -e APP_URL \
  -e STOREFRONT_PROXY_PORT \
  -e PROJECT_ROOT \
  -e ESLINT_DISABLE \
  -e VIRTUAL_HOST="hot.${HOST}" \
  -p 80 \
  -p 9999:9999 \
  --entrypoint=npm \
  node:12 \
  --prefix vendor/shopware/platform/src/Storefront/Resources/app/storefront/ run-script hot-proxy
