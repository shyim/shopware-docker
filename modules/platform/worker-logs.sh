#!/usr/bin/env bash

cd "/var/www/html/${SHOPWARE_PROJECT}" || exit 1

tail -f var/log/worker*.log