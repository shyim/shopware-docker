#!/usr/bin/env bash

SHOPWARE_PROJECT=$2
PLUGIN=$3
MODULE=$4
export USE_SSL_DEFAULT=false
URL=$(get_url "$SHOPWARE_PROJECT")

DEFAULT_MODULES=( "Administration" "Storefront" )

cd "${CODE_DIRECTORY}/${SHOPWARE_PROJECT}" || exit

if [[ -z $PLUGIN ]]; then
  E2E_PATH="${SHOPWARE_PROJECT}/tests/e2e"
  CYPRESS_BIN="/var/www/html/${SHOPWARE_PROJECT}/tests/e2e/node_modules/.bin/cypress"
else
  PLUGIN_PATH="${SHOPWARE_PROJECT}/custom/plugins/${PLUGIN}"

  if [[ ! -d "${CODE_DIRECTORY}/${PLUGIN_PATH}" ]]; then
    echo "${red:-}Plugin ${PLUGIN} does not exist${reset:-}"
    exit 1
  fi

  E2E_PATH="${PLUGIN_PATH}/tests/e2e"

  if [[ -z $MODULE ]]; then
    # fallback to legacy setup
    if [[ ! -f "${CODE_DIRECTORY}/${E2E_PATH}/package.json" ]]; then
      echo "${warn:-}No combined e2e setup was found. Trying to fallback to legacy setup.${reset:-}"

      for m in "${DEFAULT_MODULES[@]}"; do
        CHECK_PATH="${PLUGIN_PATH}/src/Resources/app/${m,,}/test/e2e"

        if [[ -f "${CODE_DIRECTORY}/${CHECK_PATH}/package.json" ]]; then
          E2E_PATH="$CHECK_PATH"
          echo "${blue:-}Found e2e setup for module: ${m}${reset:-}"
          break
        fi
      done
    fi
  else
    E2E_PATH="${PLUGIN_PATH}/src/Resources/app/${MODULE,,}/test/e2e"
  fi

  CYPRESS_BIN="/var/www/html/${E2E_PATH}/node_modules/.bin/cypress"

  if [[ ! -f "${CODE_DIRECTORY}/${E2E_PATH}/package.json" ]]; then
    if [[ -z $MODULE ]]; then
      echo "${red:-}No e2e setup found for plugin ${PLUGIN}${reset:-}"
    else
      echo "${red:-}No e2e setup found for module ${MODULE} in plugin ${PLUGIN}${reset:-}"
    fi

    exit 1
  fi

  compose exec -w "/var/www/html/${SHOPWARE_PROJECT}" cli php bin/console plugin:refresh

  PLUGIN_ACTIVE=$(echo "SELECT active FROM plugin WHERE name = '${PLUGIN}' LIMIT 1" | compose exec -T mysql mysql -uroot -proot "$SHOPWARE_PROJECT" | grep -E -i '^[0-9]+$')

  if [[ $PLUGIN_ACTIVE -ne 1 ]]; then
    compose exec -w "/var/www/html/${SHOPWARE_PROJECT}" cli php bin/console plugin:install -a "$PLUGIN"
  fi
fi

REMOTE_E2E_PATH="/var/www/html/${E2E_PATH}"

if [[ ! -d "${CODE_DIRECTORY}/${E2E_PATH}/node_modules" ]]; then
  compose exec cli bash /opt/swdc/swdc-inside run "$2" npm install --prefix "$REMOTE_E2E_PATH"
fi

usedCypressVersion=$(docker run \
    --rm \
    -it \
    -v "${CODE_DIRECTORY}:/var/www/html" \
    -u 1000 \
    node:12-alpine \
    node "$CYPRESS_BIN" --version | grep 'version: ' | head -1 | cut -d':' -f2)

usedCypressVersion=$(trim_whitespace "$usedCypressVersion")

xhost +si:localuser:"$USER"
HOST=$(echo "$URL" | sed s/'http[s]\?:\/\/'//)
CURLHOST="Host: ${HOST}"

compose exec cli curl -H "${CURLHOST}" http://cypress-backup-proxy:8080/backup

docker run \
      --rm \
      -it \
      --name "${SHOPWARE_PROJECT}_cypress" \
      --network shopware-docker_default \
      -v "${CODE_DIRECTORY}/${SHOPWARE_PROJECT}:/var/www/html/${SHOPWARE_PROJECT}" \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      -w "$REMOTE_E2E_PATH" \
      -e DISPLAY \
      -e TZ=UTC \
      -e "CYPRESS_shopwareRoot=/var/www/html/${SHOPWARE_PROJECT}" \
      -u 1000 \
      --shm-size=2G \
      --entrypoint=cypress \
      "cypress/included:$usedCypressVersion" \
      open --project . --config baseUrl="$URL"
