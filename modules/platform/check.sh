#!/usr/bin/env bash

cd "${SHOPWARE_FOLDER}" || exit 1

if [[ "$RUN_MODE" != "local" ]]; then
  export SHOPWARE_TOOL_CACHE_ECS="/tmp/swdc-tool-cache/${SHOPWARE_PROJECT}/ecs/"

  if [[ -e phpstan.neon.dist ]]; then
  echo "includes:
  - phpstan.neon.dist

parameters:
    tmpDir: /tmp/swdc-tool-cache/${SHOPWARE_PROJECT}/phpstan
  " > phpstan.neon
  fi
fi

shift 2

RUN_ECS=1
RUN_PHPSTAN=1
RUN_PSALM=1

if [[ "$#" != 0 ]]; then
  RUN_ECS=0
  RUN_PHPSTAN=0
  RUN_PSALM=0
  while (($#)); do
    case $1 in
    ecs)
      RUN_ECS=1
      ;;
    static-analyse)
      RUN_PHPSTAN=1
      RUN_PSALM=1
      ;;
    phpstan)
      RUN_PHPSTAN=1
      ;;
    psalm)
      RUN_PSALM=1
      ;;
    esac
    shift
  done
fi

if grep -q static-analyze composer.json; then
  composer update

  if [[ "$RUN_ECS" == "1" ]]; then
    composer run ecs-fix src
  fi

  if [[ "$RUN_PHPSTAN" == "1" ]]; then
    composer run phpstan
  fi

  if [[ "$RUN_PSALM" == "1" ]]; then
    composer run psalm
  fi

  exit 0
fi

if grep -q static-analyze platform/composer.json; then
  cd platform || exit 1
  composer update

  if [[ "$RUN_ECS" == "1" ]]; then
    composer run ecs-fix src
  fi

  if [[ "$RUN_PHPSTAN" == "1" ]]; then
    composer run phpstan
  fi

  if [[ "$RUN_PSALM" == "1" ]]; then
    composer run psalm src
  fi

  exit 0
fi

composer install -d dev-ops/analyze
composer dump-autoload

php dev-ops/analyze/generate-composer.php

if [[ "$RUN_ECS" == "1" ]]; then
  if [[ -f platform/easy-coding-standard.php ]]; then
    php dev-ops/analyze/vendor/bin/ecs check --fix platform/src --config platform/easy-coding-standard.php
  else
    php dev-ops/analyze/vendor/bin/ecs check --fix platform/src --config platform/easy-coding-standard.yml
  fi
fi

if [[ "$RUN_PHPSTAN" == "1" ]]; then
  php dev-ops/analyze/phpstan-config-generator.php
  php dev-ops/analyze/vendor/bin/phpstan analyze --autoload-file=dev-ops/analyze/vendor/autoload.php --configuration platform/phpstan.neon
fi

if [[ "$RUN_PSALM" == "1" ]]; then
  php dev-ops/analyze/vendor/bin/psalm --config=vendor/shopware/platform/psalm.xml --threads=$(($(nproc) / 2)) --show-info=false
fi

composer run bc-check