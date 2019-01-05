#!/usr/bin/env bash

phpVersions=(php56 php70 php71 php72 php73)
mysqlVersions=(55 56 57 8)

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
