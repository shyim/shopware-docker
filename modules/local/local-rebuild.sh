#!/usr/bin/env bash

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
node "${DIR}/images/twig.js" "${DIR}/images/custom/nginx/Dockerfile.twig" "{\"phpVersion\": \":${dockerPHP}\", \"xdebug\": false}" > "${DIR}/images/custom/nginx/Dockerfile"
if [[ "${mysqlVersions}" != "" ]]; then
    node "${DIR}/images/twig.js" "${DIR}/images/custom/mysql/Dockerfile.twig" "{\"mysqlVersion\": \":${dockerPHP}\"}" > "${DIR}/images/custom/mysql/Dockerfile"
fi
docker-compose build --force-rm --no-cache --pull
swdc local-up
