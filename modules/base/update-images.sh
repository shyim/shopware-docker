#!/usr/bin/env bash

docker-compose -f ${DOCKER_COMPOSE_FILE} pull
docker-compose -f ${DOCKER_COMPOSE_FILE} up -d --remove-orphans