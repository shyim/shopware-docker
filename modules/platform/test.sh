#!/usr/bin/env bash

checkParameter
clearCache
cd "/var/www/html/${SHOPWARE_PROJECT}" || exit 1

composer dump-autoload

if [[ $3 == "--with-coverage" ]]; then
  php -d memory_limit=-1 -d pcov.enabled=1 -d pcov.directory=/var/www/html/"${SHOPWARE_PROJECT}" vendor/bin/phpunit -c vendor/shopware/platform/phpunit.xml.dist --coverage-html build/artifacts/phpunit-coverage-html "${@:4}"
else
  php -d memory_limit=-1 vendor/bin/phpunit -c vendor/shopware/platform/phpunit.xml.dist "${@:3}"
fi
