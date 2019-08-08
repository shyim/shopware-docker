#!/usr/bin/env bash

source "${DIR}/.env"
source "${DIR}/modules/defaults/base-up.sh"

CODE_FOLDER_CONTENT="$(ls -A ${CODE_DIRECTORY})"

MYSQL_VERSION=$(echo ${MYSQL_VERSION} | sed 's/\.//g')
PHP_VERSION=$(echo ${PHP_VERSION} | sed 's/\.//g')


echo "version: '3'" > "${DIR}/docker-compose.override.yaml"
echo "services:" >> "${DIR}/docker-compose.override.yaml"
if [[ -f "${DIR}/images/custom/nginx/Dockerfile" ]]; then
    echo "  nginx:" >> "${DIR}/docker-compose.override.yaml"
    echo "    build:" >> "${DIR}/docker-compose.override.yaml"
    echo "      context: ${DIR}/images/custom/nginx/" >> "${DIR}/docker-compose.override.yaml"
    echo "      dockerfile: ${DIR}/images/custom/nginx/Dockerfile" >> "${DIR}/docker-compose.override.yaml"
    if [[ ${CODE_FOLDER_CONTENT} ]]; then
    echo "    extra_hosts:" >> "${DIR}/docker-compose.override.yaml"
    for d in ${CODE_DIRECTORY}/* ; do
        if [[ -d "$d" ]]; then
            NAME=$(basename $d)
            if [[ -f "$d/public/index.php" ]]; then
                echo "      ${NAME}.platform.localhost: 127.0.0.1" >> "${DIR}/docker-compose.override.yaml"
            else
                echo "      ${NAME}.dev.localhost: 127.0.0.1" >> "${DIR}/docker-compose.override.yaml"
            fi
        fi
    done
    echo "    volumes:" >> "${DIR}/docker-compose.override.yaml"
    echo "      - ${CODE_DIRECTORY}:/var/www/html:cached" >> "${DIR}/docker-compose.override.yaml"
    for d in ${CODE_DIRECTORY}/* ; do
        if [[ -d "$d" ]]; then
            NAME=$(basename $d)
            echo "      - ${CODE_DIRECTORY}/${NAME}/media:/var/www/html/${NAME}/media:cached" >> "${DIR}/docker-compose.override.yaml"
            echo "      - ${CODE_DIRECTORY}/${NAME}/files:/var/www/html/${NAME}/files:cached" >> "${DIR}/docker-compose.override.yaml"
            if [[ ${CACHE_VOLUMES} == "true" ]]; then
                echo "      - ${NAME}_var_cache:/var/www/html/${NAME}/var/cache:delegated" >> "${DIR}/docker-compose.override.yaml"
                echo "      - ${NAME}_web_cache:/var/www/html/${NAME}/web/cache:delegated" >> "${DIR}/docker-compose.override.yaml"
            else
                echo "      - ${CODE_DIRECTORY}/${NAME}/var/cache:/var/www/html/${NAME}/var/cache:delegated" >> "${DIR}/docker-compose.override.yaml"
                echo "      - ${CODE_DIRECTORY}/${NAME}/web/cache:/var/www/html/${NAME}/web/cache:delegated" >> "${DIR}/docker-compose.override.yaml"
            fi
        fi
    done
fi
else
    create_nginx
fi
if [[ -f "${DIR}/images/custom/mysql/Dockerfile" ]]; then
echo "  mysql:" >> "${DIR}/docker-compose.override.yaml"
    echo "    build:" >> "${DIR}/docker-compose.override.yaml"
    echo "      context: ${DIR}/images/custom/mysql/" >> "${DIR}/docker-compose.override.yaml"
    echo "      dockerfile: ${DIR}/images/custom/mysql/Dockerfile" >> "${DIR}/docker-compose.override.yaml"
    if [[ ${EXPOSE_MYSQL_LOCAL} == "true" ]]; then
        echo "    ports:" >> "${DIR}/docker-compose.override.yaml"
        echo "      - 3306:3306" >> "${DIR}/docker-compose.override.yaml"
    fi
    if [[ ${PERSISTENT_DATABASE} == "false" ]]; then
        echo "    tmpfs:" >> "${DIR}/docker-compose.override.yaml"
        echo "      - /var/lib/mysql" >> "${DIR}/docker-compose.override.yaml"
    else
        echo "    volumes:" >> "${DIR}/docker-compose.override.yaml"
        for d in ${CODE_DIRECTORY}/* ; do
            if [[ -d "$d" ]]; then
                NAME=$(basename $d)
                echo "      - ./mysql-data:/var/lib/mysql:delegated" >> "${DIR}/docker-compose.override.yaml"
            fi
        done
    fi
else
    create_mysql
fi
create_ci

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

docker-compose up -d --remove-orphans
