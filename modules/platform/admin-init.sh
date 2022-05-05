#!/usr/bin/env bash

checkParameter

cd "${SHOPWARE_FOLDER}" || exit 1

setup_node_version

ADMINISTRATION_PATH=$(platform_component Administration)

if [[ -e "$ADMINISTRATION_PATH/Resources/lerna.json" ]]; then
  npm install --prefix "$ADMINISTRATION_PATH/Resources"
  npm run --prefix "$ADMINISTRATION_PATH/Resources" lerna -- bootstrap
else
  npm clean-install --prefix "$ADMINISTRATION_PATH/Resources/app/administration/"
fi