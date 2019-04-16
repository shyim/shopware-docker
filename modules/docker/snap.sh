#!/usr/bin/env bash

SNAP_SUFFIX="$3"
SNAP_DIR="/var/www/html/snapshots"

if [[ ! -z "$SNAP_SUFFIX" ]]; then
    SNAP_SUFFIX=$(echo "-${SNAP_SUFFIX}")
fi

if [[ ! -d "$SNAP_DIR" ]]; then
  mkdir "$SNAP_DIR"
fi

checkParameter
mysqldump -h mysql -uroot -proot ${SHOPWARE_PROJECT} > /var/www/html/snapshots/${SHOPWARE_PROJECT}${SNAP_SUFFIX}.sql