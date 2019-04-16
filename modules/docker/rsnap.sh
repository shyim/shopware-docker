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
if [[ ! -f "$SNAP_DIR/${SHOPWARE_PROJECT}${SNAP_SUFFIX}.sql" ]]; then
  echo "Snap for shop ${SHOPWARE_PROJECT} does not exists"
  exit 1
fi
mysql -h mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS $SHOPWARE_PROJECT"
bash -c "mysql -h mysql -uroot -proot ${SHOPWARE_PROJECT} < /var/www/html/snapshots/${SHOPWARE_PROJECT}${SNAP_SUFFIX}.sql"