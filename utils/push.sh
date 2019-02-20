#!/usr/bin/env bash

FILE="$0"

if [ -L "$0" ]; then
  FILE=$(readlink "$0")
fi

DIR=$(dirname ${FILE})

source "${DIR}/functions.sh"


for t in ${phpVersions[@]}; do
    docker push shyim/shopware-cli:${t}
    docker push shyim/shopware-nginx:${t}
done

docker push shyim/shopware-nginx:php72-xdebug
docker push shyim/shopware-nginx:php71-xdebug
docker push shyim/shopware-nginx:php56-xdebug

for t in ${mysqlVersions[@]}; do
    docker push shyim/shopware-mysql:${t}
done
