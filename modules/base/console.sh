#!/usr/bin/env bash
set -euo pipefail

checkParameter

SHOPWARE_PROJECT=$2
shift 2

compose run \
  --rm \
  -T \
  --no-deps \
  -u "$(id -u):$(id -g)" \
  --entrypoint="bin/console" \
  -w "/var/www/html/$SHOPWARE_PROJECT" \
  cli "$@"
