#!/usr/bin/env bash

checkParameter
clearCache
cd "${SHOPWARE_FOLDER}" || exit 1

composer dump-autoload

PHPUNIT_XML=vendor/shopware/platform/phpunit.xml.dist

if [[ -e phpunit.xml.dist ]]; then
  PHPUNIT_XML=phpunit.xml.dist
fi

if [[ $3 == "--with-coverage" ]]; then
  php -d memory_limit=-1 -d pcov.enabled=1 -d pcov.directory=/var/www/html/"${SHOPWARE_PROJECT}" vendor/bin/phpunit -c ${PHPUNIT_XML} --coverage-html build/artifacts/phpunit-coverage-html "${@:4}"
else
  php -d memory_limit=-1 vendor/bin/phpunit -c ${PHPUNIT_XML} "${@:3}"
fi
