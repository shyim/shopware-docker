#!/usr/bin/env bash

docker exec -it shopwaredocker_app_$2_1 php /opt/var-dumper-server/bin/console server:dump ${@:3}
