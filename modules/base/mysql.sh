#!/usr/bin/env bash

docker-compose -f ${DOCKER_COMPOSE_FILE} exec -e COLUMNS="`tput cols`" -e LINES="`tput lines`" -e SHELL=bash -u 0 mysql mysql -uroot -p${MYSQL_ROOT_PASSWORD} "${@:2}"
