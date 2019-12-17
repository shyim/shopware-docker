#!/usr/bin/env bash

docker exec -it shopware-docker_app_$2_1 php /opt/var-dumper-server/bin/console server:dump ${@:3}