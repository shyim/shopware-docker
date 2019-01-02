#!/usr/bin/env bash

for filename in ./nginx/*; do
    cp -R ssl/ $filename/rootfs/etc/nginx/ssl
done

cd cli/72
docker build -t shyim/shopware-cli:php72 .

cd ..

cd 56
docker build -t shyim/shopware-cli:php56 .

cd ../..

cd nginx/73
docker build -t shyim/shopware-nginx:php73 .

cd ..
cd 72
docker build -t shyim/shopware-nginx:php72 .

cd ..
cd 72-xdebug
docker build -t shyim/shopware-nginx:php72-xdebug .

cd ..
cd 71
docker build -t shyim/shopware-nginx:php71 .

cd ..
cd 71-xdebug
docker build -t shyim/shopware-nginx:php71-xdebug .


cd ..
cd 56
docker build -t shyim/shopware-nginx:php56 .

cd ..
cd 56-xdebug
docker build -t shyim/shopware-nginx:php56-xdebug .

cd ../..
cd mysql/8
docker build -t shyim/shopware-mysql:8 .

cd ..
cd 55
docker build -t shyim/shopware-mysql:55 .

cd ..
cd 56
docker build -t shyim/shopware-mysql:56 .

cd ..
cd 57
docker build -t shyim/shopware-mysql:57 .