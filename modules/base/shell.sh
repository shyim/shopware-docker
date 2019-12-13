#!/usr/bin/env bash

docker-compose -f ${DOCKER_COMPOSE_FILE} exec -e COLUMNS="`tput cols`" -e LINES="`tput lines`" -e SHELL=bash cli bash