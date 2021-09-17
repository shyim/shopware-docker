#!/usr/bin/env bash

SNAP_SUFFIX="$3"
SNAP_DIR="${CODE_DIRECTORY}/snapshots"
CONTAINER=$4

if [[ -z $CONTAINER ]]; then
  CONTAINER="mysql"
fi

if [[ -n "$SNAP_SUFFIX" ]]; then
  SNAP_SUFFIX=$(echo "-${SNAP_SUFFIX}")
fi

if [[ ! -d "$SNAP_DIR" ]]; then
  mkdir "$SNAP_DIR"
fi

checkParameter

compose exec -T $CONTAINER mysqldump -uroot -p"${MYSQL_ROOT_PASSWORD}" --hex-blob "${SHOPWARE_PROJECT}" | LANG=C LC_CTYPE=C LC_ALL=C sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' >"${SNAP_DIR}/${SHOPWARE_PROJECT}${SNAP_SUFFIX}.sql"
