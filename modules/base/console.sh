#!/usr/bin/env bash
set -euo pipefail

SHOPWARE_PROJECT=$2
shift 2

docker-compose -f "$DOCKER_COMPOSE_FILE" run \
  --rm \
  --no-deps \
  -u "$(id -u):$(id -g)" \
  --entrypoint="bin/console" \
  -w "/var/www/html/$SHOPWARE_PROJECT" \
  cli "$@"
