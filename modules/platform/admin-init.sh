checkParameter

cd "/var/www/html/${SHOPWARE_PROJECT}"

if [[ -e vendor/shopware/platform ]]; then
    npm install --prefix vendor/shopware/platform/src/Administration/Resources/app/administration/
else
    npm install --prefix vendor/shopware/administration/Resources/app/administration/
fi
