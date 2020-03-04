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
        cp nginx/10-classic.conf nginx/rootfs/etc/nginx/sites-enabled/www.conf
        docker build -t shyim/shopware-classic-nginx:${t} -f ./nginx/${t}/Dockerfile ./nginx/

        cp nginx/10-platform.conf nginx/rootfs/etc/nginx/sites-enabled/www.conf
        docker build -t shyim/shopware-platform-nginx:${t} -f ./nginx/${t}/Dockerfile ./nginx/
    fi

    if [[ $1 == "xdebug" || $1 == "all" ]]; then
        if [[ -d "./nginx/${t}-xdebug" ]]; then
            cp nginx/10-classic.conf nginx/rootfs/etc/nginx/sites-enabled/www.conf
            docker build -t shyim/shopware-classic-nginx:${t}-xdebug -f ./nginx/${t}-xdebug/Dockerfile ./nginx/

            cp nginx/10-platform.conf nginx/rootfs/etc/nginx/sites-enabled/www.conf
            docker build -t shyim/shopware-platform-nginx:${t}-xdebug -f ./nginx/${t}-xdebug/Dockerfile ./nginx/
        fi
    fi

    if [[ $1 == "cli-xdebug" || $1 == "all" ]]; then
        if [[ -d "./cli/${t}-xdebug" ]]; then
            docker build -t shyim/shopware-cli:${t}-xdebug -f ./cli/${t}-xdebug/Dockerfile ./cli/
        fi
    fi

    if [[ $1 == "blackfire" || $1 == "all" ]]; then
        if [[ -d "./nginx/${t}-blackfire" ]]; then
            cp nginx/10-classic.conf nginx/rootfs/etc/nginx/sites-enabled/www.conf
            docker build -t shyim/shopware-classic-nginx:${t}-blackfire -f ./nginx/${t}-blackfire/Dockerfile ./nginx/

            cp nginx/10-platform.conf nginx/rootfs/etc/nginx/sites-enabled/www.conf
            docker build -t shyim/shopware-platform-nginx:${t}-blackfire -f ./nginx/${t}-blackfire/Dockerfile ./nginx/
        fi
    fi
done

if [[ $1 == "mysql" || $1 == "all" ]]; then
    for t in ${mysqlVersions[@]}; do
        echo "Building mysql container for $t"
        docker build -t shyim/shopware-mysql:${t} ./mysql/${t}
    done
fi