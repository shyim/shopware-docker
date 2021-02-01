#!/usr/bin/env bash

checkParameter

CONTAINER=$3

if [[ -z $CONTAINER ]]; then
  CONTAINER="mysql"
fi

echo "DROP DATABASE $SHOPWARE_PROJECT" | compose exec -T mysql mysql -uroot -p"${MYSQL_ROOT_PASSWORD}"
