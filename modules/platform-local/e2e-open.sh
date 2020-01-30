SHOPWARE_PROJECT=$2
URL=$(get_url $SHOPWARE_PROJECT)

cd "${CODE_DIRECTORY}/${SHOPWARE_PROJECT}"

if [[ ! -d "vendor/shopware/platform/src/Administration/Resources/app/administration/test/e2e" ]]; then
    npm clean-install --prefix vendor/shopware/platform/src/Administration/Resources/app/administration/test/e2e
fi

export CYPRESS_BASE_URL=$URL

docker-compose -f ${DOCKER_COMPOSE_FILE} exec cli node /var/www/html/${SHOPWARE_PROJECT}/vendor/shopware/platform/src/Administration/Resources/app/administration/test/e2e/node_modules/@shopware-ag/e2e-testsuite-platform/routes/cypress.js &

cd vendor/shopware/platform/src/Administration/Resources/app/administration/test/e2e

node_modules/.bin/cypress open --config baseUrl=$URL --env localUsage=false,projectRoot="${CODE_DIRECTORY}/${SHOPWARE_PROJECT}";