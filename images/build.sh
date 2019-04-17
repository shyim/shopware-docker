#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail


DIR=$(dirname $0)

source "${DIR}/../functions.sh"

for t in ${phpVersions[@]}; do
    if [[ $1 == "cli" || $1 == "all" ]]; then
        echo "Building cli container for $t"
        docker build -t shyim/shopware-cli:${t} -f ./cli/${t}/Dockerfile ./cli/
    fi

    if [[ $1 == "nginx" || $1 == "all" ]]; then
        echo "Building nginx container for $t"
        docker build -t shyim/shopware-nginx:${t} -f ./nginx/${t}/Dockerfile ./nginx/
    fi

    if [[ $1 == "xdebug" || $1 == "all" ]]; then
        if [[ -d "./nginx/${t}-xdebug" ]]; then
            docker build -t shyim/shopware-nginx:${t}-xdebug -f ./nginx/${t}-xdebug/Dockerfile ./nginx/
        fi
    fi
done

if [[ $1 == "mysql" || $1 == "all" ]]; then
    for t in ${mysqlVersions[@]}; do
        echo "Building mysql container for $t"
        docker build -t shyim/shopware-mysql:${t} ./mysql/${t}
    done
fi