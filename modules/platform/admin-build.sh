checkParameter

cd "/var/www/html/${SHOPWARE_PROJECT}"
export PROJECT_ROOT="/var/www/html/${SHOPWARE_PROJECT}"

bin/console bundle:dump
npm run --prefix vendor/shopware/platform/src/Administration/Resources/app/administration/ build
bin/console assets:install
