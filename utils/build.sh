#!/usr/bin/env bash

FILE="$0"

if [ -L "$0" ]; then
  FILE=$(readlink "$0")
fi

DIR=$(dirname ${FILE})

source "${DIR}/functions.sh"

for t in ${phpVersions[@]}; do
    echo "Building cli container for $t"
    docker build -t shyim/shopware-cli:${t} -f ./cli/${t}/Dockerfile ./cli/

    echo "Building nginx container for $t"
    docker build -t shyim/shopware-nginx:${t} -f ./nginx/${t}/Dockerfile ./nginx/

    if [[ -d "./nginx/${t}-xdebug" ]]; then
        docker build -t "shyim/shopware-nginx:${t}-xdebug" "./nginx/${t}-xdebug"
    fi
done

for t in ${mysqlVersions[@]}; do
    echo "Building cli container for $t"
    docker build -t shyim/shopware-mysql:${t} ./mysql/${t}
done