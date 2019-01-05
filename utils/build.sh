#!/usr/bin/env bash

phpVersions=(php56 php70 php71 php72 php73)
mysqlVersions=(55 56 57 8)

# Copy rootfs
for t in ${phpVersions[@]}; do
    if [[ $t == "php56" ]]; then
        continue
    fi

    cp -R nginx/php56/rootfs nginx/${t}/rootfs
done

for t in ${phpVersions[@]}; do
    echo "Building cli container for $t"
    docker build -t shyim/shopware-cli:${t} ./cli/${t}

    echo "Building nginx container for $t"
    docker build -t shyim/shopware-nginx:${t} ./nginx/${t}

    if [[ -d "./nginx/${t}-xdebug" ]]; then
        docker build -t "shyim/shopware-nginx:${t}-xdebug" "./nginx/${t}-xdebug"
    fi
done

for t in ${mysqlVersions[@]}; do
    echo "Building cli container for $t"
    docker build -t shyim/shopware-mysql:${t} ./mysql/${t}
done