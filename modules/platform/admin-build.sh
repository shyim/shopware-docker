checkParameter

cd "/var/www/html/${SHOPWARE_PROJECT}"
export PROJECT_ROOT="/var/www/html/${SHOPWARE_PROJECT}"
export ENV_FILE="${PROJECT_ROOT}/.env"

bin/console bundle:dump

if [[ -e vendor/shopware/platform ]]; then
    npm run --prefix vendor/shopware/platform/src/Administration/Resources/app/administration/ build
else
    npm run --prefix vendor/shopware/administration/Resources/app/administration/ build
fi

bin/console assets:install
