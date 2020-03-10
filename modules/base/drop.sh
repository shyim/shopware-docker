#!/usr/bin/env bash

checkParameter

docker-compose -f ${DOCKER_COMPOSE_FILE} exec mysql mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "DROP DATABASE $SHOPWARE_PROJECT"