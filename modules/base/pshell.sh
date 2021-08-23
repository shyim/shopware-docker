#!/usr/bin/env bash

set -e

checkParameter

shift

PROJECT_NAME=$1

shift

if [[ -z "$1" ]]; then
  compose exec -w "/var/www/html/$PROJECT_NAME" -e COLUMNS -e LINES -e SHELL=bash cli bash
else
  PHP_VERSION=default

  while (($#)); do
    case $1 in
    --php-version)
      shift
      PHP_VERSION=$1
      ;;
    *)
      break
      ;;
    esac

    shift
  done

  if [[ $PHP_VERSION == 'default' ]]; then
    compose exec -T -w "/var/www/html/$PROJECT_NAME" -e COLUMNS -e LINES -e SHELL=bash cli "$@"
  else
    docker run \
      --rm \
      -it \
      -w "/var/www/html/$PROJECT_NAME" \
      --env-file="${REALDIR}/docker.env" \
      --env-file="${REALDIR}/.env.dist" \
      --env=file=~/.config/swdc/env \
      --network shopware-docker_default \
      -v shopware-docker_nvm_cache:/nvm \
      -v "$CODE_DIRECTORY:/var/www/html/" \
      -v "/.config/swdc/:/swdc-cfg" \
      "ghcr.io/shyim/shopware-docker/cli:php$PHP_VERSION" "$@"
  fi
fi
