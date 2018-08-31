#!/usr/bin/env bash

cd cli
docker build -t shyim/shopware-cli:php72 .

cd ..

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
cd 56
docker build -t shyim/shopware-nginx:php56 .

cd ../..
cd mysql/8
docker build -t shyim/shopware-mysql:8
