#!/usr/bin/env bash

CONTAINER="$2"

if [[ -z $CONTAINER ]]; then
  CONTAINER="mysql"
else
  shift
fi

compose exec -e COLUMNS="$(tput cols)" -e LINES="$(tput lines)" -e SHELL=bash -u 0 "${CONTAINER}" mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" "${@:2}"
