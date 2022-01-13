#!/usr/bin/env bash

checkParameter

cd "${SHOPWARE_FOLDER}" || exit 1

shift 2

FILE="config/packages/swdc.yml"

touch "$FILE"

yq e -i "$1" "$FILE"