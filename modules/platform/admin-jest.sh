checkParameter

cd "/var/www/html/${SHOPWARE_PROJECT}"
export PROJECT_ROOT="/var/www/html/${SHOPWARE_PROJECT}"
export ENV_FILE="${PROJECT_ROOT}/.env"
PLATFORM_PATH=$(platform_component Administration)
export ADMIN_PATH="$PLATFORM_PATH/Resources/app/administration/"

npm run --prefix $PLATFORM_PATH/Resources/app/administration/ unit-watch
