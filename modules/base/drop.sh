#!/usr/bin/env bash

checkParameter

compose exec mysql mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "DROP DATABASE $SHOPWARE_PROJECT"