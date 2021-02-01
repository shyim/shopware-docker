#!/usr/bin/env bash

SNAP_SUFFIX="$3"
SNAP_DIR="${CODE_DIRECTORY}/snapshots"
CONTAINER=$4

if [[ -z $CONTAINER ]]; then
    CONTAINER="mysql"
fi


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

echo "CREATE DATABASE IF NOT EXISTS $SHOPWARE_PROJECT" | compose exec -T $CONTAINER mysql -uroot -p${MYSQL_ROOT_PASSWORD}
cat "${SNAP_DIR}/${SHOPWARE_PROJECT}${SNAP_SUFFIX}.sql" | compose exec -T $CONTAINER mysql -uroot -p${MYSQL_ROOT_PASSWORD} ${SHOPWARE_PROJECT}