#!/usr/bin/env bash

checkParameter

cd "/var/www/html/${SHOPWARE_PROJECT}" || exit 1

ADMINISTRATION_PATH=$(platform_component Administration)

if [[ -e "$ADMINISTRATION_PATH/Resources/lerna.json" ]]; then
  npm clean-install --prefix "$ADMINISTRATION_PATH/Resources"
  npm run --prefix "$ADMINISTRATION_PATH/Resources" lerna -- bootstrap
else
  npm clean-install --prefix "$ADMINISTRATION_PATH/Resources/app/administration/"
fi