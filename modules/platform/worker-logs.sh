#!/usr/bin/env bash

cd "${SHOPWARE_FOLDER}" || exit 1

tail -f var/log/worker*.log