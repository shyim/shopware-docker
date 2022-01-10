#!/usr/bin/env bash

checkParameter
clearCache
cd "/var/www/html/${SHOPWARE_PROJECT}" || exit 1

export PROJECT_ROOT=$SHOPWARE_FOLDER
export SHOPWARE_INSTALL=1

composer run paratest