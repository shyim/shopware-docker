#!/usr/bin/env bash

additionalArgs=""
if [[ -e "${HOME}/.config/swdc/services.yml" ]]; then
  additionalArgs=" -f ${HOME}/.config/swdc/services.yml"
fi

CONTAINER=$2

if [[ -z $CONTAINER ]]; then
  CONTAINER="mysql"
fi

watch -n0.1 "docker-compose -f ${DOCKER_COMPOSE_FILE} $additionalArgs exec -e COLUMNS=\"$(tput cols)\" -e LINES=\"$(tput lines)\" -e SHELL=bash -u 0 $CONTAINER mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e 'SHOW processlist'"
