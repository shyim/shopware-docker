#!/usr/bin/env bash

docker-compose exec nginx php /opt/var-dumper-server/bin/console server:dump ${@:2}