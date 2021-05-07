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
  docker run \
    --rm \
    -it \
    -v "${CODE_DIRECTORY}:/var/www/html" \
    -u 1000 \
    node:12-alpine \
    npm install --prefix "${E2E_PATH}"
fi

xhost +si:localuser:root
HOST=$(echo "$URL" | sed s/'http[s]\?:\/\/'//)
CURLHOST="Host: ${HOST}"

compose exec cli curl -H "${CURLHOST}" http://cypress-backup-proxy:8080/backup

docker run \
      --rm \
      -it \
      --name "${SHOPWARE_PROJECT}_cypress" \
      --network shopware-docker_default \
      --link "app_${SHOPWARE_PROJECT}:${HOST}" \
      -v "${CODE_DIRECTORY}/${SHOPWARE_PROJECT}:/var/www/html/${SHOPWARE_PROJECT}" \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      -w "${E2E_PATH}" \
      -e DISPLAY \
      -u 1000 \
      --shm-size=2G \
      --entrypoint=cypress \
      cypress/included:5.6.0 \
      open --project . --config baseUrl="$URL"
