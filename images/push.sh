#!/usr/bin/env bash

DIR=$(dirname $0)

source "${DIR}/../functions.sh"


for t in ${phpVersions[@]}; do
    if [[ $1 == "cli" || $1 == "all" ]]; then
        docker push shyim/shopware-cli:${t}
    fi

    if [[ $1 == "nginx" || $1 == "all" ]]; then
        docker push shyim/shopware-classic-nginx:${t}
        docker push shyim/shopware-platform-nginx:${t}
    fi
done

if [[ $1 == "xdebug" || $1 == "all" ]]; then
    docker push shyim/shopware-nginx:php72-xdebug
    docker push shyim/shopware-nginx:php71-xdebug
    docker push shyim/shopware-nginx:php56-xdebug
fi

if [[ $1 == "mysql" || $1 == "all" ]]; then
    for t in ${mysqlVersions[@]}; do
        docker push shyim/shopware-mysql:${t}
    done
fi