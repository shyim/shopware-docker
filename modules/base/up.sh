#!/usr/bin/env bash

source "${HOME}/.swdc_env"
source "${DIR}/modules/defaults.sh"

CODE_FOLDER_CONTENT="$(ls -A ${CODE_DIRECTORY})"

MYSQL_VERSION=$(echo ${MYSQL_VERSION} | sed 's/\.//g')
PHP_VERSION=$(echo ${PHP_VERSION} | sed 's/\.//g')
XDEBUG_VERSION="$(check_xdebug ${2})"
check_php "${2}"

export DOCKER_OVERRIDE_FILE="/tmp/swdc-docker-compose-override.yml";

echo "version: '3'" > ${DOCKER_OVERRIDE_FILE}
echo "services:" >> ${DOCKER_OVERRIDE_FILE}

create_nginx
create_mysql
create_cli

# Build alias for cli
if [[ ${ENABLE_ELASTICSEARCH} == "true" ]]; then
    create_es
fi

if [[ ${ENABLE_REDIS} == "true" ]]; then
    create_redis
fi

if [[ ${ENABLE_MINIO} == "true" ]]; then
    create_minio
fi

create_database_tool

if [[ ${ENABLE_SELENIUM} == "true" ]]; then
    create_selenium
fi

if [[ ${ENABLE_BLACKFIRE} == "true" ]]; then
    create_blackfire
fi

if [[ ${CACHE_VOLUMES} == "true" ]]; then
    create_caching
fi

docker-compose -f ${DIR}/docker-compose.yml -f ${DOCKER_OVERRIDE_FILE} up -d --remove-orphans
