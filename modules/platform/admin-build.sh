checkParameter

cd "/var/www/html/${SHOPWARE_PROJECT}"
export PROJECT_ROOT="/var/www/html/${SHOPWARE_PROJECT}"

bin/console bundle:dump

if [[ -e vendor/shopware/platform ]]; then
    npm install --prefix vendor/shopware/platform/src/Administration/Resources/app/administration/
    npm run --prefix vendor/shopware/platform/src/Administration/Resources/app/administration/ build
else
    npm install --prefix vendor/shopware/administration/Resources/app/administration/
    npm run --prefix vendor/shopware/administration/Resources/app/administration/ build
fi

bin/console assets:install
