#!/usr/bin/env bash

source ".env"

MYSQL_VERSION=$(echo ${MYSQL_VERSION} | sed 's/\.//g')
PHP_VERSION=$(echo ${PHP_VERSION} | sed 's/\.//g')

echo "version: '3'" > "${DIR}/docker-compose.override.yaml"
echo "services:" >> "${DIR}/docker-compose.override.yaml"
echo "  nginx:" >> "${DIR}/docker-compose.override.yaml"
echo "    image: shyim/shopware-nginx:php${PHP_VERSION}" >> "${DIR}/docker-compose.override.yaml"
echo "  mysql:" >> "${DIR}/docker-compose.override.yaml"
echo "    image: shyim/shopware-mysql:${MYSQL_VERSION}" >> "${DIR}/docker-compose.override.yaml"

if [[ $PERSISTENT_DATABASE == "false" ]]; then
    echo "    tmpfs:" >> "${DIR}/docker-compose.override.yaml"
    echo "      - /var/lib/mysql" >> "${DIR}/docker-compose.override.yaml"
fi

# Build alias for cli
echo "  cli:" >> "${DIR}/docker-compose.override.yaml"
echo "    links:" >> "${DIR}/docker-compose.override.yaml"
for d in ~/Code/* ; do
    if [[ -d "$d" ]]; then
        NAME=$(basename $d)
        if [[ -f "$d/src/RequestTransformer.php" ]]; then
            echo "      - nginx:${NAME}.platform.localhost" >> "${DIR}/docker-compose.override.yaml"
        else
            echo "      - nginx:${NAME}.dev.localhost" >> "${DIR}/docker-compose.override.yaml"
        fi
    fi
done

if [[ $ENABLE_ELASTICSEARCH == "true" ]]; then
    echo "  elastic:" >> "${DIR}/docker-compose.override.yaml"
    echo "    image: elasticsearch:${ELASTICSEARCH_VERSION}" >> "${DIR}/docker-compose.override.yaml"
    echo "    ports:" >> "${DIR}/docker-compose.override.yaml"
    echo "      - 9200:9200" >> "${DIR}/docker-compose.override.yaml"
fi

if [[ $ENABLE_REDIS == "true" ]]; then
    echo "  redis:" >> "${DIR}/docker-compose.override.yaml"
    echo "    image: redis:5-alpine" >> "${DIR}/docker-compose.override.yaml"
fi

if [[ $ENABLE_MINIO == "true" ]]; then
    echo "  minio:" >> "${DIR}/docker-compose.override.yaml"
    echo "    image: minio/minio" >> "${DIR}/docker-compose.override.yaml"
    echo "    env_file: docker.env" >> "${DIR}/docker-compose.override.yaml"
    echo "    command: server /data" >> "${DIR}/docker-compose.override.yaml"
    echo "    ports:" >> "${DIR}/docker-compose.override.yaml"
    echo "      - 9000:9000" >> "${DIR}/docker-compose.override.yaml"
fi

if [[ $DATABASE_TOOL == "adminer" ]]; then
    echo "  adminer:" >> "${DIR}/docker-compose.override.yaml"
    echo "    image: adminer" >> "${DIR}/docker-compose.override.yaml"
    echo "    env_file: docker.env" >> "${DIR}/docker-compose.override.yaml"
    echo "    ports:" >> "${DIR}/docker-compose.override.yaml"
    echo "      - 8080:8080" >> "${DIR}/docker-compose.override.yaml"
fi

if [[ $DATABASE_TOOL == "phpmyadmin" ]]; then
    echo "  phpmyadmin:" >> "${DIR}/docker-compose.override.yaml"
    echo "    image: phpmyadmin/phpmyadmin" >> "${DIR}/docker-compose.override.yaml"
    echo "    env_file: docker.env" >> "${DIR}/docker-compose.override.yaml"
    echo "    ports:" >> "${DIR}/docker-compose.override.yaml"
    echo "      - 8080:80" >> "${DIR}/docker-compose.override.yaml"
fi

if [[ $ENABLE_SELENIUM == "true" ]]; then
    echo "  selenium:" >> "${DIR}/docker-compose.override.yaml"
    echo "    image: selenium/standalone-chrome:3.8.1" >> "${DIR}/docker-compose.override.yaml"
    echo "    shm_size: 2g" >> "${DIR}/docker-compose.override.yaml"
    echo "    environment:" >> "${DIR}/docker-compose.override.yaml"
    echo "      DBUS_SESSION_BUS_ADDRESS: /dev/null" >> "${DIR}/docker-compose.override.yaml"
    echo "    links:" >> "${DIR}/docker-compose.override.yaml"

    for d in ~/Code/* ; do
        if [[ -f "$d/src/RequestTransformer.php" ]]; then
            echo "      - nginx:${NAME}.platform.localhost" >> "${DIR}/docker-compose.override.yaml"
        else
            echo "      - nginx:${NAME}.dev.localhost" >> "${DIR}/docker-compose.override.yaml"
        fi
    done
fi

docker-compose up -d --remove-orphans