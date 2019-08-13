#!/usr/bin/env bash

source "${HOME}/.swdc_env"
source "${DIR}/modules/defaults/base-up.sh"

CODE_FOLDER_CONTENT="$(ls -A ${CODE_DIRECTORY})"

MYSQL_VERSION=$(echo ${MYSQL_VERSION} | sed 's/\.//g')
PHP_VERSION=$(echo ${PHP_VERSION} | sed 's/\.//g')
export DOCKER_OVERRIDE_FILE="/tmp/swdc-docker-compose-override.yml";


echo "version: '3'" > ${DOCKER_OVERRIDE_FILE}
echo "services:" >> ${DOCKER_OVERRIDE_FILE}
if [[ -f "${DIR}/images/custom/nginx/Dockerfile" ]]; then
    echo "  nginx:" >> ${DOCKER_OVERRIDE_FILE}
    echo "    build:" >> ${DOCKER_OVERRIDE_FILE}
    echo "      context: ${DIR}/images/custom/nginx/" >> ${DOCKER_OVERRIDE_FILE}
    echo "      dockerfile: ${DIR}/images/custom/nginx/Dockerfile" >> ${DOCKER_OVERRIDE_FILE}
    if [[ ${CODE_FOLDER_CONTENT} ]]; then
    echo "    extra_hosts:" >> ${DOCKER_OVERRIDE_FILE}
    for d in ${CODE_DIRECTORY}/* ; do
        if [[ -d "$d" ]]; then
            NAME=$(basename $d)
            if [[ -f "$d/public/index.php" ]]; then
                echo "      ${NAME}.platform.localhost: 127.0.0.1" >> ${DOCKER_OVERRIDE_FILE}
            else
                echo "      ${NAME}.dev.localhost: 127.0.0.1" >> ${DOCKER_OVERRIDE_FILE}
            fi
        fi
    done
    echo "    volumes:" >> ${DOCKER_OVERRIDE_FILE}
    echo "      - ${CODE_DIRECTORY}:/var/www/html:cached" >> ${DOCKER_OVERRIDE_FILE}
    for d in ${CODE_DIRECTORY}/* ; do
        if [[ -d "$d" ]]; then
            NAME=$(basename $d)
            echo "      - ${CODE_DIRECTORY}/${NAME}/media:/var/www/html/${NAME}/media:cached" >> ${DOCKER_OVERRIDE_FILE}
            echo "      - ${CODE_DIRECTORY}/${NAME}/files:/var/www/html/${NAME}/files:cached" >> ${DOCKER_OVERRIDE_FILE}
            if [[ ${CACHE_VOLUMES} == "true" ]]; then
                echo "      - ${NAME}_var_cache:/var/www/html/${NAME}/var/cache:delegated" >> ${DOCKER_OVERRIDE_FILE}
                echo "      - ${NAME}_web_cache:/var/www/html/${NAME}/web/cache:delegated" >> ${DOCKER_OVERRIDE_FILE}
            else
                echo "      - ${CODE_DIRECTORY}/${NAME}/var/cache:/var/www/html/${NAME}/var/cache:delegated" >> ${DOCKER_OVERRIDE_FILE}
                echo "      - ${CODE_DIRECTORY}/${NAME}/web/cache:/var/www/html/${NAME}/web/cache:delegated" >> ${DOCKER_OVERRIDE_FILE}
            fi
        fi
    done
fi
else
    create_nginx
fi
if [[ -f "${DIR}/images/custom/mysql/Dockerfile" ]]; then
echo "  mysql:" >> ${DOCKER_OVERRIDE_FILE}
    echo "    build:" >> ${DOCKER_OVERRIDE_FILE}
    echo "      context: ${DIR}/images/custom/mysql/" >> ${DOCKER_OVERRIDE_FILE}
    echo "      dockerfile: ${DIR}/images/custom/mysql/Dockerfile" >> ${DOCKER_OVERRIDE_FILE}
    if [[ ${EXPOSE_MYSQL_LOCAL} == "true" ]]; then
        echo "    ports:" >> ${DOCKER_OVERRIDE_FILE}
        echo "      - 3306:3306" >> ${DOCKER_OVERRIDE_FILE}
    fi
    if [[ ${PERSISTENT_DATABASE} == "false" ]]; then
        echo "    tmpfs:" >> ${DOCKER_OVERRIDE_FILE}
        echo "      - /var/lib/mysql" >> ${DOCKER_OVERRIDE_FILE}
    else
        echo "    volumes:" >> ${DOCKER_OVERRIDE_FILE}
        for d in ${CODE_DIRECTORY}/* ; do
            if [[ -d "$d" ]]; then
                NAME=$(basename $d)
                echo "      - ./mysql-data:/var/lib/mysql:delegated" >> ${DOCKER_OVERRIDE_FILE}
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

docker-compose -f ${DIR}/docker-compose.yml -f ${DOCKER_OVERRIDE_FILE} up -d --remove-orphans
