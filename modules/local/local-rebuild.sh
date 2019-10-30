#!/usr/bin/env bash

export DOCKER_OVERRIDE_FILE="/tmp/swdc-docker-compose-override.yml";

swdc local-up
if [[ "$2" == "" ]]; then
    phpVersionNumeric=72
else
    phpVersionNumeric="${2}"
fi
dockerPHP="$(echo "php${phpVersionNumeric}")"
xdebugPhpVersions="${phpVersionNumeric}"
mysqlVersions="${3}"


npm install twig
if [[ ! -f "${DIR}/images/custom/nginx/Dockerfile" ]]; then
    node "${DIR}/images/twig.js" "${DIR}/images/custom/nginx/Dockerfile.twig" "{\"phpVersion\": \":${dockerPHP}\", \"xdebug\": false}" > "${DIR}/images/custom/nginx/Dockerfile"
fi
if [[ ! -f "${DIR}/images/custom/mysql/Dockerfile" ]]; then
    if [[ "${mysqlVersions}" != "" ]]; then
        node "${DIR}/images/twig.js" "${DIR}/images/custom/mysql/Dockerfile.twig" "{\"mysqlVersion\": \":${dockerPHP}\"}" > "${DIR}/images/custom/mysql/Dockerfile"
    fi
fi

cp -r "${DIR}/docker.env" /tmp/docker.env
docker-compose -f $DOCKER_OVERRIDE_FILE build --force-rm --no-cache --pull
swdc local-up
