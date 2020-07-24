checkParameter

cd "/var/www/html/${SHOPWARE_PROJECT}"

if [[ -e vendor/shopware/platform ]]; then
    pnpm install -C vendor/shopware/platform/src/Administration/Resources/app/administration/
else
    pnpm install -C vendor/shopware/administration/Resources/app/administration/
fi
