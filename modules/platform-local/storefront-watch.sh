#!/usr/bin/env bash

LOCAL_PROJECT_ROOT="${CODE_DIRECTORY}/${SHOPWARE_PROJECT}"
cd "$LOCAL_PROJECT_ROOT" || exit
PLATFORM_PATH=$(platform_component Storefront)
LOCAL_WEBPACK_CONFIG="${LOCAL_PROJECT_ROOT}/${PLATFORM_PATH}Resources/app/storefront/webpack.config.js"
export USE_SSL_DEFAULT=false
URL=$(get_url "$SHOPWARE_PROJECT")
HOST=$(echo "$URL" | sed s/'http[s]\?:\/\/'//)
WATCHER_URL="storefront-${SHOPWARE_PROJECT}.${DEFAULT_DOMAIN}"

if [[ -e "${LOCAL_WEBPACK_CONFIG}" ]]; then
    localhostPound=$(grep "host: '127.0.0.1'" < "${LOCAL_WEBPACK_CONFIG}")
    
    if [[ -n "$localhostPound" ]]; then
        docker exec -t -w "/var/www/html/${SHOPWARE_PROJECT}/" shopware-docker_cli_1 ./bin/console theme:dump

        echo "Starting watcher at host http://${WATCHER_URL}"
        docker run \
            --rm \
            --name "${SHOPWARE_PROJECT}_storefront_watch" \
            --network shopware-docker_default \
            --link "shopware-docker_app_${SHOPWARE_PROJECT}:${HOST}" \
            -v "$LOCAL_PROJECT_ROOT:/var/www/html/${SHOPWARE_PROJECT}" \
            -e PORT=80 \
            -e HOST="0.0.0.0" \
            -e ESLINT_DISABLE=true \
            -e "APP_URL=$URL" \
            -e PROJECT_ROOT="/var/www/html/${SHOPWARE_PROJECT}" \
            -e ENV_FILE="/var/www/html/${SHOPWARE_PROJECT}/.env" \
            -e STOREFRONT_PROXY_PORT=80 \
            -e PROXY_URL="http://${WATCHER_URL}" \
            -e "VIRTUAL_HOST=$WATCHER_URL" \
            -w "/var/www/html/${SHOPWARE_PROJECT}" \
            --expose 80 \
            node:12-alpine \
            npm run --prefix "$PLATFORM_PATH"/Resources/app/storefront/ hot-proxy
        exit 0
    fi
fi

compose exec cli bash /opt/swdc/swdc-inside storefront-watch "${SHOPWARE_PROJECT}"
