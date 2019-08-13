#!/usr/bin/env bash

export DOCKER_OVERRIDE_FILE="/tmp/swdc-docker-compose-override.yml";

docker-compose -f ${DIR}/docker-compose.yml -f ${DOCKER_OVERRIDE_FILE} down
