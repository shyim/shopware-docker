#!/usr/bin/env bash

checkParameter

cd "${SHOPWARE_FOLDER}" || exit 1
export PROJECT_ROOT="/var/www/html/${SHOPWARE_PROJECT}"
export ENV_FILE="${PROJECT_ROOT}/.env"
ADMINISTRATION_PATH="${PROJECT_ROOT}/$(platform_component Administration)"
PLUGIN=$3

bin/console framework:schema -s 'entity-schema' "${ADMINISTRATION_PATH}Resources/app/administration/test/_mocks_/entity-schema.json"

setup_node_version

if [[ -z $PLUGIN ]]; then
  JEST_PATH="${ADMINISTRATION_PATH}Resources/app/administration"
else
  JEST_PATH="/var/www/html/${SHOPWARE_PROJECT}/custom/plugins/${PLUGIN}/src/Resources/app/administration"

  bin/console plugin:refresh

  PLUGIN_ACTIVE=$(echo "SELECT active FROM plugin WHERE name = '${PLUGIN}' LIMIT 1" | mysql -h mysql -uroot -proot "$SHOPWARE_PROJECT" | grep -E -i '^[0-9]+$')

  if [[ $PLUGIN_ACTIVE -ne 1 ]]; then
    bin/console plugin:install -a "$PLUGIN"
  fi
fi

npm run --prefix "$JEST_PATH" unit-watch