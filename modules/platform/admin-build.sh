#!/usr/bin/env bash

checkParameter

cd "/var/www/html/${SHOPWARE_PROJECT}" || exit 1
export PROJECT_ROOT="/var/www/html/${SHOPWARE_PROJECT}"
export ENV_FILE="${PROJECT_ROOT}/.env"

bin/console bundle:dump
bin/console feature:dump || true

PLATFORM_PATH=$(platform_component Administration)

if [[ ! -f "${PLATFORM_PATH}/Resources/app/administration/" ]]; then
  echo "Build failed:"
  echo "=> Run swdc admin-init ${SHOPWARE_PROJECT} first."
  exit 1
fi

npm run --prefix "$PLATFORM_PATH"/Resources/app/administration/ build

bin/console assets:install
