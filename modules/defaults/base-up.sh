#!/usr/bin/env bash

function create_nginx (){
    echo "  nginx:" >> "${DIR}/docker-compose.override.yaml"
    if [[ -z $XDEBUG_VERSION ]]; then
        echo "    image: shyim/shopware-nginx:php${PHP_VERSION}" >> "${DIR}/docker-compose.override.yaml"
    else
        echo "    image: shyim/shopware-nginx:php${XDEBUG_VERSION}" >> "${DIR}/docker-compose.override.yaml"
    fi
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
}

function create_mysql() {
    echo "  mysql:" >> "${DIR}/docker-compose.override.yaml"
    echo "    image: shyim/shopware-mysql:${MYSQL_VERSION}" >> "${DIR}/docker-compose.override.yaml"
    if [[ ${EXPOSE_MYSQL_LOCAL} == "true" ]]; then
        echo "    ports:" >> "${DIR}/docker-compose.override.yaml"
        echo "      - 3306:3306" >> "${DIR}/docker-compose.override.yaml"
    fi
    if [[ ${PERSISTENT_DATABASE} == "false" ]]; then
        echo "    tmpfs:" >> "${DIR}/docker-compose.override.yaml"
        echo "      - /var/lib/mysql" >> "${DIR}/docker-compose.override.yaml"
    else
        echo "    volumes:" >> "${DIR}/docker-compose.override.yaml"
        echo "      - ./mysql-data:/var/lib/mysql:delegated" >> "${DIR}/docker-compose.override.yaml"
    fi
}

function create_ci () {
    echo "  cli:" >> "${DIR}/docker-compose.override.yaml"
    if [[ ${CODE_FOLDER_CONTENT} ]]; then
        echo "    links:" >> "${DIR}/docker-compose.override.yaml"
        for d in ${CODE_DIRECTORY}/* ; do
            if [[ -d "$d" ]]; then
                NAME=$(basename $d)
                if [[ -f "$d/public/index.php" ]]; then
                    echo "      - nginx:${NAME}.platform.localhost" >> "${DIR}/docker-compose.override.yaml"
                else
                    echo "      - nginx:${NAME}.dev.localhost" >> "${DIR}/docker-compose.override.yaml"
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
}

function create_es () {
    echo "  elastic:" >> "${DIR}/docker-compose.override.yaml"
    echo "    image: docker.elastic.co/elasticsearch/elasticsearch:${ELASTICSEARCH_VERSION}" >> "${DIR}/docker-compose.override.yaml"

    echo "  cerebro:" >> "${DIR}/docker-compose.override.yaml"
    echo "    image: lmenezes/cerebro" >> "${DIR}/docker-compose.override.yaml"
}

function create_redis () {
    echo "  redis:" >> "${DIR}/docker-compose.override.yaml"
    echo "    image: redis:5-alpine" >> "${DIR}/docker-compose.override.yaml"
}

function create_minio () {
    echo "  minio:" >> "${DIR}/docker-compose.override.yaml"
    echo "    image: minio/minio" >> "${DIR}/docker-compose.override.yaml"
    echo "    env_file: docker.env" >> "${DIR}/docker-compose.override.yaml"
    echo "    command: server /data" >> "${DIR}/docker-compose.override.yaml"
    echo "    ports:" >> "${DIR}/docker-compose.override.yaml"
    echo "      - 9000:9000" >> "${DIR}/docker-compose.override.yaml"
}

function create_database_tool () {
    if [[ ${DATABASE_TOOL} == "phpmyadmin" ]]; then
        echo "  phpmyadmin:" >> "${DIR}/docker-compose.override.yaml"
        echo "    image: phpmyadmin/phpmyadmin" >> "${DIR}/docker-compose.override.yaml"
        echo "    env_file: docker.env" >> "${DIR}/docker-compose.override.yaml"
    else
        echo "  adminer:" >> "${DIR}/docker-compose.override.yaml"
        echo "    image: adminer" >> "${DIR}/docker-compose.override.yaml"
        echo "    env_file: docker.env" >> "${DIR}/docker-compose.override.yaml"
    fi
}

function create_selenium () {
    echo "  selenium:" >> "${DIR}/docker-compose.override.yaml"
    echo "    image: selenium/standalone-chrome:3.8.1" >> "${DIR}/docker-compose.override.yaml"
    echo "    shm_size: 2g" >> "${DIR}/docker-compose.override.yaml"
    echo "    environment:" >> "${DIR}/docker-compose.override.yaml"
    echo "      DBUS_SESSION_BUS_ADDRESS: /dev/null" >> "${DIR}/docker-compose.override.yaml"

    if [[ ${CODE_FOLDER_CONTENT} ]]; then
        echo "    links:" >> "${DIR}/docker-compose.override.yaml"

        for d in ${CODE_DIRECTORY}/* ; do
            if [[ -f "$d/public/index.php" ]]; then
                echo "      - nginx:${NAME}.platform.localhost" >> "${DIR}/docker-compose.override.yaml"
            else
                echo "      - nginx:${NAME}.dev.localhost" >> "${DIR}/docker-compose.override.yaml"
            fi
        done
    fi
}

function create_blackfire () {
    echo "  blackfire:" >> "${DIR}/docker-compose.override.yaml"
    echo "    image: blackfire/blackfire" >> "${DIR}/docker-compose.override.yaml"
    echo "    environment:" >> "${DIR}/docker-compose.override.yaml"
    echo "      BLACKFIRE_SERVER_ID: ${BLACKFIRE_SERVER_ID}" >> "${DIR}/docker-compose.override.yaml"
    echo "      BLACKFIRE_SERVER_TOKEN: ${BLACKFIRE_SERVER_TOKEN}" >> "${DIR}/docker-compose.override.yaml"
}

function create_caching () {
    if [[ ${CODE_FOLDER_CONTENT} ]]; then
        echo "volumes:" >> "${DIR}/docker-compose.override.yaml"
        for d in ${CODE_DIRECTORY}/* ; do
            if [[ -d "$d" ]]; then
                NAME=$(basename $d)
                echo "  ${NAME}_var_cache:" >> "${DIR}/docker-compose.override.yaml"
                echo "    driver: local" >> "${DIR}/docker-compose.override.yaml"
                echo "  ${NAME}_web_cache:" >> "${DIR}/docker-compose.override.yaml"
                echo "    driver: local" >> "${DIR}/docker-compose.override.yaml"
            fi
        done
    fi
}
