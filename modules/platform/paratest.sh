#!/usr/bin/env bash

checkParameter
clearCache
cd "${SHOPWARE_FOLDER}" || exit 1

export PROJECT_ROOT=$SHOPWARE_FOLDER

composer run paratest