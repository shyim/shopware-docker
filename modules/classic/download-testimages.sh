#!/usr/bin/env bash

checkParameter

SNAP_DIR="/var/www/html/snapshots"

if [[ ! -d "$SNAP_DIR" ]]; then
  mkdir "$SNAP_DIR"
fi

if [[ ! -f "${SNAP_DIR}/test_images.zip" ]]; then
  wget -O ${SNAP_DIR}/test_images.zip http://releases.s3.shopware.com/test_images_since_5.1.zip
fi

unzip -o ${SNAP_DIR}/test_images.zip -d "${SHOPWARE_FOLDER}"/
