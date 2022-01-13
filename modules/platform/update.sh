#!/usr/bin/env bash

checkParameter
clearCache
cd "${SHOPWARE_FOLDER}" || exit 1

CORE_PATH=$(platform_component Core)

composer update

if [[ -d $CORE_PATH/Framework/App ]]; then
  bin/console database:migrate --all
  bin/console database:migrate-destructive --all
else

  if ! bin/console database:migrate --all Shopware\\; then
    bin/console database:migrate --all
    bin/console database:migrate-destructive --all
  else
    bin/console database:migrate-destructive --all Shopware\\
  fi
fi

./bin/console theme:compile