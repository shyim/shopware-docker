#!/usr/bin/env bash

cd "/var/www/html/${SHOPWARE_PROJECT}" || exit 1

while true; do
  php bin/console messenger:consume --memory-limit=1G -vv
done
