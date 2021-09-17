#!/usr/bin/env bash

cd /var/www/html/"$SHOPWARE_PROJECT" || exit 1
export USE_SSL_DEFAULT=false
HOST=$(get_host "$SHOPWARE_PROJECT")

php "${DIR}"/modules/classic/fix-config.php "$SHOPWARE_FOLDER/config.php" csrf

./bin/console dbal:run-sql 'UPDATE s_core_config_elements SET value = "b:0;" WHERE name = "show_cookie_note"'
./bin/console dbal:run-sql 'UPDATE s_core_shops SET secure = 0'

./bin/console sw:rebuild:seo:index
./bin/console sw:cache:clear

# Shopware 5.7
if [[ -f engine/Shopware/Shopware.php ]]; then
  make .make.config.behat
else
  sed -e "s/%sw\.host%/$(HOST)/g" -e "s/%sw\.path%//g" < ./build/behat.yml.dist > ./tests/Mink/behat.yml
fi

vendor/bin/behat -vv --config=tests/Mink/behat.yml --format=pretty --out=std --format=junit --out=build/artifacts/mink "${@:3}"
