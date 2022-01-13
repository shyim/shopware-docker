#!/usr/bin/env bash

checkParameter
clearCache

PROJECT_ROOT="${CODE_DIRECTORY}/$SHOPWARE_PROJECT"
cd "${PROJECT_ROOT}" || exit 1

bin/console bundle:dump

npm --prefix "${PROJECT_ROOT}/custom/b2b/components/SwagB2bPlatform/Resources/app/storefront/" run production

bin/console theme:compile