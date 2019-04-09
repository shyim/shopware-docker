#!/usr/bin/env bash

# Coloring/Styling helpers
esc=$(printf '\033')
reset="${esc}[0m"
blue="${esc}[34m"
green="${esc}[32m"
red="${esc}[31m"
bold="${esc}[1m"
warn="${esc}[41m${esc}[97m"

phpVersions=(php56 php70 php71 php72 php73)
xdebugPhpVersions=(php70 php71 php72)
mysqlVersions=(55 56 57 8)


function fixHooks()
{
    rm ${SHOPWARE_FOLDER}/.git/hooks/pre-commit
    cd ${SHOPWARE_FOLDER}
    ln -s ../../build/gitHooks/pre-commit .git/hooks/pre-commit
    echo "Hooks fixed"
}

function clearCache()
{
    rm -r ${SHOPWARE_FOLDER}/var/cache/production_*
    rm -r ${SHOPWARE_FOLDER}/var/cache/testing_*
    rm -r ${SHOPWARE_FOLDER}/var/cache/docker_*
}

function fixDeveloperConfig()
{
    php ${DIR}/utils/fix-config.php "$SHOPWARE_FOLDER/config.php" $1
}

function checkParameter()
{
    if [ -z "$SHOPWARE_PROJECT" ]; then
        echo "Please enter a shopware folder name"
        exit 1
    fi

    if [ ! -d "$SHOPWARE_FOLDER" ]; then
        echo "Folder $SHOPWARE_FOLDER does not exists!"
        exit 1
    fi
}

function applyFixture()
{
  if [ -z "$FIXTURE_NAME" ]; then
    echo "Please enter a fixture name"
    exit 1
  fi

  if [ ! -e "${DIR}/fixtures/${FIXTURE_NAME}.sql" ]; then
    echo "Fixture by name ${FIXTURE_NAME} does not exist"
    exit 1
  fi
  mysql -h mysql -u root -proot $SHOPWARE_PROJECT < "${DIR}/fixtures/${FIXTURE_NAME}.sql"
}

function isComposerProject()
{
    if [ -d "$SHOPWARE_FOLDER/app" ]; then
        echo "true"
    fi
}

function buildComposerProjectEnvFile()
{
  echo "SHOPWARE_VERSION_TEXT=\"$SHOPWARE_PROJECT (local docker)\"" >> "$SHOPWARE_FOLDER/.env"
  echo "SHOPWARE_REVISION=\"`git rev-parse HEAD`\"" >> "$SHOPWARE_FOLDER/.env"
  echo "DATABASE_URL=\"mysql://root:root@mysql:3306/$SHOPWARE_PROJECT\"" >> "$SHOPWARE_FOLDER/.env"
  echo 'ADMIN_EMAIL="demo@demo.com"' >> "$SHOPWARE_FOLDER/.env"
  echo 'ADMIN_NAME="Don Joe"' >> "$SHOPWARE_FOLDER/.env"
  echo 'ADMIN_USERNAME="demo"' >> "$SHOPWARE_FOLDER/.env"
  echo 'ADMIN_PASSWORD="demo"' >> "$SHOPWARE_FOLDER/.env"
  echo "SHOP_URL=\"http://$SHOPWARE_PROJECT.dev.localhost\"" >> "$SHOPWARE_FOLDER/.env"
  echo 'IMPORT_DEMODATA=y' >> "$SHOPWARE_FOLDER/.env"
}

function generateDockerComposeOverride()
{
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
        if [ -d "$d" ]; then
            NAME=$(basename $d)
            echo "      - nginx:${NAME}.dev.localhost" >> "${DIR}/docker-compose.override.yaml"
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
            if [ -d "$d" ]; then
                NAME=$(basename $d)
                echo "      - nginx:${NAME}.dev.localhost" >> "${DIR}/docker-compose.override.yaml"
            fi
        done
    fi

}
