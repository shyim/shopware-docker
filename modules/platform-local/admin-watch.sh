#!/usr/bin/env bash

export DOCKER_COMPOSE_FILE="/tmp/swdc-docker-compose.yml"
LOCAL_PROJECT_ROOT="${CODE_DIRECTORY}/${SHOPWARE_PROJECT}"
cd "$LOCAL_PROJECT_ROOT" || exit
PLATFORM_PATH=$(platform_component Administration)
LOCAL_WEBPACK_CONFIG="${LOCAL_PROJECT_ROOT}/${PLATFORM_PATH}Resources/app/administration/webpack.config.js"
export USE_SSL_DEFAULT=false
URL=$(get_url "$SHOPWARE_PROJECT")
WATCHER_URL="admin-${SHOPWARE_PROJECT}.${DEFAULT_DOMAIN}"
NODE_VERSION=$(get_node_version)

if [[ "$RUN_MODE" == "local" ]]; then
    export PROJECT_ROOT=$LOCAL_PROJECT_ROOT
    export APP_URL=$URL
    export ESLINT_DISABLE=true
    exec npm run --prefix "$PLATFORM_PATH"/Resources/app/administration/ dev
fi

if [[ -e "${LOCAL_WEBPACK_CONFIG}" ]]; then
    disabledHostCheck=$(grep disableHostCheck < "${LOCAL_WEBPACK_CONFIG}")
    
    if [[ -n "$disabledHostCheck" ]]; then
        "$0" console "${SHOPWARE_PROJECT}" bundle:dump
        "$0" console "${SHOPWARE_PROJECT}" feature:dump || true

        echo "Starting watcher at host http://${WATCHER_URL}"
        docker run \
            --rm \
            -it \
            --name "${SHOPWARE_PROJECT}_admin_watch" \
            --network shopware-docker_default \
            -v "$LOCAL_PROJECT_ROOT:/var/www/html" \
            -e PORT=80 \
            -e HOST="0.0.0.0" \
            -e ESLINT_DISABLE=true \
            -e "APP_URL=$URL" \
            -e PROJECT_ROOT="/var/www/html" \
            -e ENV_FILE="/var/www/html/.env" \
            -e "VIRTUAL_HOST=$WATCHER_URL" \
            -w "/var/www/html" \
            --expose 80 \
            node:"$NODE_VERSION" \
            npm run --prefix "$PLATFORM_PATH"/Resources/app/administration/ dev
        exit 0
    fi
fi

compose exec cli bash /opt/swdc/swdc-inside admin-watch "${SHOPWARE_PROJECT}"
