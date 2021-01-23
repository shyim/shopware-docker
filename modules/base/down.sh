#!/usr/bin/env bash

docker-compose -f ${DOCKER_COMPOSE_FILE} down

if [[ -e "$REALDIR/xdebug.sock" ]]; then
    rm "$REALDIR/xdebug.sock"
fi