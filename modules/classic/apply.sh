#!/usr/bin/env bash

checkParameter

FIXTURE_NAME=$3

if [[ -z "$FIXTURE_NAME" ]]; then
echo "Please enter a fixture name"
exit 1
fi

if [[ ! -e "${DIR}/modules/classic/fixtures/${FIXTURE_NAME}.sql" ]]; then
echo "Fixture by name ${FIXTURE_NAME} does not exist"
exit 1
fi
mysql -h mysql -u root -p'${MYSQL_ROOT_PASSWORD}' ${SHOPWARE_PROJECT} < "${DIR}/modules/classic/fixtures/${FIXTURE_NAME}.sql"