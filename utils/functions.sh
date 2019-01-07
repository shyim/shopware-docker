#!/usr/bin/env bash

set -o errexit
set -o pipefail

# Coloring/Styling helpers
esc=$(printf '\033')
reset="${esc}[0m"
blue="${esc}[34m"
green="${esc}[32m"
red="${esc}[31m"
bold="${esc}[1m"
warn="${esc}[41m${esc}[97m"


function fixHooks()
{
    rm ${SHOPWARE_FOLDER}/.git/hooks/pre-commit
    ln -s ${SHOPWARE_FOLDER}/build/gitHooks/pre-commit ${SHOPWARE_FOLDER}/.git/hooks/pre-commit
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
  docker-compose run --rm cli mysql -h mysql -u root -proot $SHOPWARE_PROJECT < "${DIR}/fixtures/${FIXTURE_NAME}.sql"
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

function generateVersionSwitch()
{
    PHP_VERSION=$1
    MYSQL_VERSION=$2

    if [[ -z ${PHP_VERSION} ]]; then
        echo "Please give a PHP version"
        exit 1
    fi

    if [[ -z ${MYSQL_VERSION} ]]; then
        echo "Using MySQL 5.7 as default"
        MYSQL_VERSION="57"
    fi

    MYSQL_VERSION=$(echo ${MYSQL_VERSION} | sed 's/\.//g')
    PHP_VERSION=$(echo ${PHP_VERSION} | sed 's/\.//g')

    echo "version: '2'" > "${DIR}/docker-compose.override.yaml"
    echo "services:" >> "${DIR}/docker-compose.override.yaml"
    echo "  nginx:" >> "${DIR}/docker-compose.override.yaml"
    echo "    image: shyim/shopware-nginx:php${PHP_VERSION}" >> "${DIR}/docker-compose.override.yaml"
    echo "  mysql:" >> "${DIR}/docker-compose.override.yaml"
    echo "    image: shyim/shopware-mysql:${MYSQL_VERSION}" >> "${DIR}/docker-compose.override.yaml"


    echo "${green}";
    echo "Generated a docker-compose.override.yaml for PHP: ${PHP_VERSION} and MySQL: ${MYSQL_VERSION}";
    echo "${reset}";

}