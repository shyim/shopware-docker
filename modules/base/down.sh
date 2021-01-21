#!/usr/bin/env bash

docker-compose -f ${DOCKER_COMPOSE_FILE} down

rm "$REALDIR/xdebug.sock"