#!/usr/bin/env bash

checkParameter
php /var/www/html/${SHOPWARE_PROJECT}/bin/console sw:snippets:to:db --include-plugins
clearCache