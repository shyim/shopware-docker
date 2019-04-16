#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail


DIR=$(dirname $0)

source "${DIR}/../functions.sh"

for t in ${phpVersions[@]}; do
    echo "Building cli container for $t"
    docker build -t shyim/shopware-cli:${t} -f ./cli/${t}/Dockerfile ./cli/

    echo "Building nginx container for $t"
    docker build -t shyim/shopware-nginx:${t} -f ./nginx/${t}/Dockerfile ./nginx/

    if [[ -d "./nginx/${t}-xdebug" ]]; then
        docker build -t shyim/shopware-nginx:${t}-xdebug -f ./nginx/${t}-xdebug/Dockerfile ./nginx/
    fi
done

for t in ${mysqlVersions[@]}; do
    echo "Building cli container for $t"
    docker build -t shyim/shopware-mysql:${t} ./mysql/${t}
done