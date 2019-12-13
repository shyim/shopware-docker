#!/usr/bin/env bash

docker-compose -f ${DOCKER_COMPOSE_FILE} exec -e COLUMNS="`tput cols`" -e LINES="`tput lines`" -e SHELL=bash -u 0 cli mysql -uroot -p${MYSQL_ROOT_PASSWORD} -hmysql "${@:2}"
