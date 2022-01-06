#!/usr/bin/env bash

checkParameter
clearCache

export PROJECT_ROOT="/var/www/html/$SHOPWARE_PROJECT"
export ENV_FILE="${PROJECT_ROOT}/.env"

B2B_ROOT="${PROJECT_ROOT}/custom/b2b"

cd "${B2B_ROOT}" || exit 1
php "${B2B_ROOT}/dev-ops/common/validate_json.php"

cp -rf "${B2B_ROOT}/dev-ops/common/templates/routes.xml" "${B2B_ROOT}/components/SwagB2bPlatform/Resources/config/routes.xml"

cp -rf "${B2B_ROOT}/dev-ops/package/templates/composer.json" "${B2B_ROOT}/composer.json"

B2B_COMPOSER="${B2B_ROOT}/composer.json"
PLATFORM_COMPOSER="${PROJECT_ROOT}/composer.json"


if [[ "$(jq 'has("repositories")' "$PLATFORM_COMPOSER")" == "true" ]]; then
  if [[ "$(jq '.repositories | any(.url != "custom/b2b")' "$PLATFORM_COMPOSER")" == "true" ]]; then
    jq '.repositories[.repositories | length] |= . + {"type":"path", "url": "custom/b2b"}' "$PLATFORM_COMPOSER" > "$PLATFORM_COMPOSER"
  fi
else
  jq '.repositories = [{"type":"path", "url": "custom/b2b"}]' "$PLATFORM_COMPOSER" > "$PLATFORM_COMPOSER"
fi

php -r "file_put_contents(\"${PLATFORM_COMPOSER}\", json_encode(json_decode(file_get_contents(\"${PLATFORM_COMPOSER}\"), true), JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));"
php -r "file_put_contents(\"${B2B_COMPOSER}\", json_encode(json_decode(file_get_contents(\"${B2B_COMPOSER}\"), true), JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));"

B2B_VERSION=$(php "${B2B_ROOT}/dev-ops/package/version.php")

echo $(jq --arg v "$B2B_VERSION" '.version = $v | .autoload["psr-4"]["SwagB2bPlatform\\"] = "components/SwagB2bPlatform"' "$B2B_COMPOSER") > "$B2B_COMPOSER"

npm clean-install --prefix "${B2B_ROOT}/components/SwagB2bPlatform/Resources/app/storefront/"

cd "${PROJECT_ROOT}" || exit 1

composer require shopware/b2b

bin/console bundle:dump

npm --prefix "${B2B_ROOT}/components/SwagB2bPlatform/Resources/app/storefront/" run production

bin/console theme:compile

bin/console plugin:refresh
bin/console plugin:install SwagB2bPlatform --activate --verbose

bin/console bundle:dump
bin/console feature:dump || true

PLATFORM_PATH=$(platform_component Administration)

if [[ ! -d "${PLATFORM_PATH}/Resources/app/administration/" ]]; then
  echo "Build failed:"
  echo "=> Run swdc admin-init ${SHOPWARE_PROJECT} first."
  exit 1
fi

npm run --prefix "$PLATFORM_PATH"/Resources/app/administration/ build

bin/console assets:install
