#/bin/bash

cd cli
docker build -t shyim/shopware-cli:php71 .

cd ..
echo $(pwd)
cd nginx/72
docker build -t shyim/shopware-nginx:php72 .

cd ..
cd 72-xdebug
docker build -t shyim/shopware-nginx:php72-xdebug .

cd ..
cd 56
docker build -t shyim/shopware-nginx:php56 .
