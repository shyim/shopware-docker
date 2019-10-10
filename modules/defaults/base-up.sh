#!/usr/bin/env bash

export Platform=$(uname -s)

function create_nginx (){
    echo "  nginx:" >> ${DOCKER_OVERRIDE_FILE}
    if [[ -z $XDEBUG_VERSION ]]; then
        echo "    image: shyim/shopware-nginx:php${PHP_VERSION}" >> ${DOCKER_OVERRIDE_FILE}
    else
        echo "    image: shyim/shopware-nginx:php${XDEBUG_VERSION}" >> ${DOCKER_OVERRIDE_FILE}
    fi
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
        if [[ ${Platform} != "Linux" ]]; then
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
    fi
}

function create_mysql() {
    echo "  mysql:" >> ${DOCKER_OVERRIDE_FILE}
    echo "    image: shyim/shopware-mysql:${MYSQL_VERSION}" >> ${DOCKER_OVERRIDE_FILE}
    if [[ ${EXPOSE_MYSQL_LOCAL} == "true" ]]; then
        echo "    ports:" >> ${DOCKER_OVERRIDE_FILE}
        echo "      - 3306:3306" >> ${DOCKER_OVERRIDE_FILE}
    fi
    if [[ ${PERSISTENT_DATABASE} == "false" ]]; then
        echo "    tmpfs:" >> ${DOCKER_OVERRIDE_FILE}
        echo "      - /var/lib/mysql" >> ${DOCKER_OVERRIDE_FILE}
    else
        echo "    volumes:" >> ${DOCKER_OVERRIDE_FILE}
        echo "      - ./mysql-data:/var/lib/mysql:delegated" >> ${DOCKER_OVERRIDE_FILE}
    fi
}

function create_cli () {
    echo "  cli:" >> ${DOCKER_OVERRIDE_FILE}
    if [[ -z $XDEBUG_VERSION ]]; then
        echo "    image: shyim/shopware-cli:php${PHP_VERSION}" >> ${DOCKER_OVERRIDE_FILE}
    else
        echo "    image: shyim/shopware-cli:php${XDEBUG_VERSION}" >> ${DOCKER_OVERRIDE_FILE}
    fi
    if [[ ${CODE_FOLDER_CONTENT} ]]; then
        echo "    links:" >> ${DOCKER_OVERRIDE_FILE}
        for d in ${CODE_DIRECTORY}/* ; do
            if [[ -d "$d" ]]; then
                NAME=$(basename $d)
                if [[ -f "$d/public/index.php" ]]; then
                    echo "      - nginx:${NAME}.platform.localhost" >> ${DOCKER_OVERRIDE_FILE}
                else
                    echo "      - nginx:${NAME}.dev.localhost" >> ${DOCKER_OVERRIDE_FILE}
                fi
            fi
        done
        if [[ ${Platform} != "Linux" ]]; then
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
    fi
}

function create_es () {
    echo "  elastic:" >> ${DOCKER_OVERRIDE_FILE}
    echo "    image: docker.elastic.co/elasticsearch/elasticsearch:${ELASTICSEARCH_VERSION}" >> ${DOCKER_OVERRIDE_FILE}

    echo "  cerebro:" >> ${DOCKER_OVERRIDE_FILE}
    echo "    image: lmenezes/cerebro" >> ${DOCKER_OVERRIDE_FILE}
}

function create_redis () {
    echo "  redis:" >> ${DOCKER_OVERRIDE_FILE}
    echo "    image: redis:5-alpine" >> ${DOCKER_OVERRIDE_FILE}
}

function create_minio () {
    echo "  minio:" >> ${DOCKER_OVERRIDE_FILE}
    echo "    image: minio/minio" >> ${DOCKER_OVERRIDE_FILE}
    echo "    env_file: docker.env" >> ${DOCKER_OVERRIDE_FILE}
    echo "    command: server /data" >> ${DOCKER_OVERRIDE_FILE}
    echo "    ports:" >> ${DOCKER_OVERRIDE_FILE}
    echo "      - 9000:9000" >> ${DOCKER_OVERRIDE_FILE}
}

function create_database_tool () {
    if [[ ${DATABASE_TOOL} == "phpmyadmin" ]]; then
        echo "  phpmyadmin:" >> ${DOCKER_OVERRIDE_FILE}
        echo "    image: phpmyadmin/phpmyadmin" >> ${DOCKER_OVERRIDE_FILE}
        echo "    env_file: docker.env" >> ${DOCKER_OVERRIDE_FILE}
    else
        echo "  adminer:" >> ${DOCKER_OVERRIDE_FILE}
        echo "    image: adminer" >> ${DOCKER_OVERRIDE_FILE}
        echo "    env_file: docker.env" >> ${DOCKER_OVERRIDE_FILE}
    fi
}

function create_selenium () {
    echo "  selenium:" >> ${DOCKER_OVERRIDE_FILE}
    echo "    image: selenium/standalone-chrome:3.8.1" >> ${DOCKER_OVERRIDE_FILE}
    echo "    shm_size: 2g" >> ${DOCKER_OVERRIDE_FILE}
    echo "    environment:" >> ${DOCKER_OVERRIDE_FILE}
    echo "      DBUS_SESSION_BUS_ADDRESS: /dev/null" >> ${DOCKER_OVERRIDE_FILE}

    if [[ ${CODE_FOLDER_CONTENT} ]]; then
        echo "    links:" >> ${DOCKER_OVERRIDE_FILE}

        for d in ${CODE_DIRECTORY}/* ; do
            NAME=$(basename $d)
            if [[ -f "$d/public/index.php" ]]; then
                echo "      - nginx:${NAME}.platform.localhost" >> ${DOCKER_OVERRIDE_FILE}
            else
                echo "      - nginx:${NAME}.dev.localhost" >> ${DOCKER_OVERRIDE_FILE}
            fi
        done
    fi
}

function create_blackfire () {
    echo "  blackfire:" >> ${DOCKER_OVERRIDE_FILE}
    echo "    image: blackfire/blackfire" >> ${DOCKER_OVERRIDE_FILE}
    echo "    environment:" >> ${DOCKER_OVERRIDE_FILE}
    echo "      BLACKFIRE_SERVER_ID: ${BLACKFIRE_SERVER_ID}" >> ${DOCKER_OVERRIDE_FILE}
    echo "      BLACKFIRE_SERVER_TOKEN: ${BLACKFIRE_SERVER_TOKEN}" >> ${DOCKER_OVERRIDE_FILE}
}

function create_caching () {
    if [[ ${CODE_FOLDER_CONTENT} ]]; then
        echo "volumes:" >> ${DOCKER_OVERRIDE_FILE}
        for d in ${CODE_DIRECTORY}/* ; do
            if [[ -d "$d" ]]; then
                NAME=$(basename $d)
                echo "  ${NAME}_var_cache:" >> ${DOCKER_OVERRIDE_FILE}
                echo "    driver: local" >> ${DOCKER_OVERRIDE_FILE}
                echo "  ${NAME}_web_cache:" >> ${DOCKER_OVERRIDE_FILE}
                echo "    driver: local" >> ${DOCKER_OVERRIDE_FILE}
            fi
        done
    fi
}
