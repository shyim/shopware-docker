checkParameter

cd "/var/www/html/${SHOPWARE_PROJECT}"

bin/console bundle:dump
npm clean-install --prefix vendor/shopware/platform/src/Administration/Resources
npm run --prefix vendor/shopware/platform/src/Administration/Resources lerna -- bootstrap
npm run --prefix vendor/shopware/platform/src/Administration/Resources/administration/ build

bin/console assets:install
