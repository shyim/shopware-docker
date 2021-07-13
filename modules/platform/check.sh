#!/usr/bin/env bash

cd "/var/www/html/${SHOPWARE_PROJECT}" || exit 1

if grep -q static-analyze composer.json; then
  composer update
  composer run ecs-fix
  composer run static-analyze

  exit 0
fi

if grep -q static-analyze platform/composer.json; then
  cd platform || exit 1
  composer update
  composer run ecs-fix
  composer run static-analyze

  exit 0
fi


composer install -d dev-ops/analyze
composer dump-autoload

php dev-ops/analyze/generate-composer.php

if [[ -f platform/easy-coding-standard.php ]]; then
  php dev-ops/analyze/vendor/bin/ecs check --fix platform/src --config platform/easy-coding-standard.php
else
  php dev-ops/analyze/vendor/bin/ecs check --fix platform/src --config platform/easy-coding-standard.yml
fi

php dev-ops/analyze/phpstan-config-generator.php
php dev-ops/analyze/vendor/bin/phpstan analyze --autoload-file=dev-ops/analyze/vendor/autoload.php --configuration platform/phpstan.neon
php dev-ops/analyze/vendor/bin/psalm --config=vendor/shopware/platform/psalm.xml --threads=$(($(nproc) / 2)) --show-info=false
