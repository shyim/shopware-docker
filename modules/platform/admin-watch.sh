#!/usr/bin/env bash

checkParameter
cd "/var/www/html/${SHOPWARE_PROJECT}"
php psh.phar administration:watch