#!/usr/bin/env bash

source "${HOME}/.swdc_env"
source "${DIR}/modules/defaults/base-up.sh"

CODE_FOLDER_CONTENT="$(ls -A ${CODE_DIRECTORY})"

MYSQL_VERSION=$(echo ${MYSQL_VERSION} | sed 's/\.//g')
PHP_VERSION=$(echo ${PHP_VERSION} | sed 's/\.//g')
export XDEBUG_ENABLE=$2

echo "version: '3.7'" > ${DOCKER_COMPOSE_FILE}
echo "services:" >> ${DOCKER_COMPOSE_FILE}

echo "  smtp:" >> ${DOCKER_COMPOSE_FILE}
echo "    image: djfarrelly/maildev" >> ${DOCKER_COMPOSE_FILE}
echo "    environment:" >> ${DOCKER_COMPOSE_FILE}
echo "      VIRTUAL_HOST: mail.localhost" >> ${DOCKER_COMPOSE_FILE}

echo "  proxy:" >> ${DOCKER_COMPOSE_FILE}
echo "    image: jwilder/nginx-proxy" >> ${DOCKER_COMPOSE_FILE}
echo "    volumes:" >> ${DOCKER_COMPOSE_FILE}
echo "      - /var/run/docker.sock:/tmp/docker.sock:ro" >> ${DOCKER_COMPOSE_FILE}
echo "      - ${REALDIR}/ssl:/etc/nginx/certs" >> ${DOCKER_COMPOSE_FILE}
echo "    ports:" >> ${DOCKER_COMPOSE_FILE}
echo "      - 80:80" >> ${DOCKER_COMPOSE_FILE}
echo "      - 443:443" >> ${DOCKER_COMPOSE_FILE}

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

docker-compose -f ${DOCKER_COMPOSE_FILE} up -d --remove-orphans
