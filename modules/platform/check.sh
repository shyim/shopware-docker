#!/usr/bin/env bash

cd "/var/www/html/${SHOPWARE_PROJECT}" || exit 1

shift 2

RUN_ECS=1
RUN_STATIC_ANALYSE=1

if [[ "$#" != 0 ]]; then
  RUN_ECS=0
  RUN_STATIC_ANALYSE=0
  while (($#)); do
    case $1 in
    ecs)
      RUN_ECS=1
      ;;
    static-analyse)
      RUN_STATIC_ANALYSE=1
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

  if [[ "$RUN_STATIC_ANALYSE" == "1" ]]; then
    composer run static-analyze
  fi

  exit 0
fi

if grep -q static-analyze platform/composer.json; then
  cd platform || exit 1
  composer update

  if [[ "$RUN_ECS" == "1" ]]; then
    composer run ecs-fix src
  fi

  if [[ "$RUN_STATIC_ANALYSE" == "1" ]]; then
    composer run static-analyze
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

if [[ "$RUN_STATIC_ANALYSE" == "1" ]]; then
  php dev-ops/analyze/phpstan-config-generator.php
  php dev-ops/analyze/vendor/bin/phpstan analyze --autoload-file=dev-ops/analyze/vendor/autoload.php --configuration platform/phpstan.neon
  php dev-ops/analyze/vendor/bin/psalm --config=vendor/shopware/platform/psalm.xml --threads=$(($(nproc) / 2)) --show-info=false
fi