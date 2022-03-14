#!/usr/bin/env bash

checkParameter
cd "${CODE_DIRECTORY}/${SHOPWARE_PROJECT}" || exit

shift 2

USERS=20
SPAWN_RATE=5
TASKS=""

if [[ -n "$1" ]]; then
    USERS=$1
fi

if [[ -n "$2" ]]; then
    SPAWN_RATE=$2
fi

if [[ -n "$3" ]]; then
    TASKS="$3"
fi

export USE_SSL_DEFAULT=false
SHOPWARE_URL=$(get_url "$SHOPWARE_PROJECT")
LOCUST_URL="locust-${SHOPWARE_PROJECT}.${DEFAULT_DOMAIN}"

echo ""
echo "Started locust ui at http://${LOCUST_URL}"
echo ""

docker run \
    --rm \
    -it \
    --name "${SHOPWARE_PROJECT}_locust" \
    --network shopware-docker_default \
    -v "${CODE_DIRECTORY}/${SHOPWARE_PROJECT}:/var/www/html/${SHOPWARE_PROJECT}" \
    -u 1000 \
    -e "VIRTUAL_HOST=$LOCUST_URL" \
    -e "VIRTUAL_PORT=8089" \
    ghcr.io/shyim/shopware-docker/locust:latest \
    -f  "/var/www/html/${SHOPWARE_PROJECT}/src/Core/DevOps/Locust/locustfile.py"\
    $TASKS \
    -H "$SHOPWARE_URL" \
    "--users=$USERS" \
    "--spawn-rate=$SPAWN_RATE" \
    --autostart
