#!/usr/bin/env bash

SNAP_SUFFIX="$3"
SNAP_DIR="${CODE_DIRECTORY}/snapshots"

if [[ ! -z "$SNAP_SUFFIX" ]]; then
    SNAP_SUFFIX=$(echo "-${SNAP_SUFFIX}")
fi

if [[ ! -d "$SNAP_DIR" ]]; then
  mkdir "$SNAP_DIR"
fi

checkParameter
if [[ ! -f "$SNAP_DIR/${SHOPWARE_PROJECT}${SNAP_SUFFIX}.sql" ]]; then
  echo "Snap for shop ${SHOPWARE_PROJECT} does not exists"
  exit 1
fi

docker-compose -f ${DOCKER_COMPOSE_FILE} exec mysql mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS $SHOPWARE_PROJECT"
docker-compose -f ${DOCKER_COMPOSE_FILE} exec -T mysql mysql -uroot -p${MYSQL_ROOT_PASSWORD} ${SHOPWARE_PROJECT} < "${SNAP_DIR}/${SHOPWARE_PROJECT}${SNAP_SUFFIX}.sql"