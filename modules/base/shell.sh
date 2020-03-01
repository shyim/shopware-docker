#!/usr/bin/env bash

if [[ -z "$2" ]]; then
  docker-compose -f ${DOCKER_COMPOSE_FILE} exec -e COLUMNS -e LINES -e SHELL=bash cli bash
else
  shift
  docker-compose -f ${DOCKER_COMPOSE_FILE} exec -e COLUMNS -e LINES -e SHELL=bash cli "$@"
fi
