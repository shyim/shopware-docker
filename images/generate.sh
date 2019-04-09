#!/usr/bin/env bash

DIR=$(dirname $0)

source "${DIR}/../utils/functions.sh"

rm -r cli/php*
rm -r nginx/php*
rm -r mysql/5*
rm -r mysql/8*

for t in ${phpVersions[@]}; do
    dockerPHP=$(echo "${t:3:1}.${t:4:1}")

    if [[ ! -d "cli/${t}" ]]; then
        mkdir cli/${t}
    fi

    if [[ ! -d "nginx/${t}" ]]; then
        mkdir nginx/${t}
    fi

    node "${DIR}/twig.js" cli/Dockerfile.twig "{\"phpVersion\": \"$dockerPHP\", \"xdebug\": false}" > cli/${t}/Dockerfile
    node "${DIR}/twig.js" nginx/Dockerfile.twig "{\"phpVersion\": \"$dockerPHP\", \"xdebug\": false}" > nginx/${t}/Dockerfile
done

for t in ${xdebugPhpVersions[@]}; do
    dockerPHP=$(echo "${t:3:1}.${t:4:1}")

    if [ ! -d "nginx/${t}-xdebug" ]; then
        mkdir nginx/${t}-xdebug
    fi

    node "${DIR}/twig.js" nginx/Dockerfile.twig "{\"phpVersion\": \"$dockerPHP\", \"xdebug\": true}" > nginx/${t}-xdebug/Dockerfile
done

for t in ${mysqlVersions[@]}; do
    if [ ! -d "mysql/${t}" ]; then
        mkdir mysql/${t}
    fi

    if [ ${t} == "8" ]; then
        mysql="8.0"
    else
        mysql=$(echo "${t:0:1}.${t:1:1}")
    fi

    node "${DIR}/twig.js" mysql/Dockerfile.twig "{\"mysqlVersion\": \"$mysql\"}" > mysql/${t}/Dockerfile
    node "${DIR}/twig.js" mysql/dev.twig "{\"mysqlVersion\": \"$mysql\"}" > mysql/${t}/dev.cnf
done