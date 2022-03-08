#!/usr/bin/env bash

checkParameter

cd "${SHOPWARE_FOLDER}" || exit 1

setup_node_version

export PROJECT_ROOT="${SHOPWARE_FOLDER}"
export ENV_FILE="${PROJECT_ROOT}/.env"

bin/console bundle:dump
bin/console feature:dump || true

PLATFORM_PATH=$(platform_component Administration)

if [[ ! -d "${PLATFORM_PATH}/Resources/app/administration/" ]]; then
  echo "Build failed:"
  echo "=> Run swdc admin-init ${SHOPWARE_PROJECT} first."
  exit 1
fi

npm run --prefix "$PLATFORM_PATH"/Resources/app/administration/ build

bin/console assets:install
