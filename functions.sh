#!/usr/bin/env bash

# Coloring/Styling helpers
esc=$(printf '\033')
reset="${esc}[0m"
blue="${esc}[34m"
green="${esc}[32m"
lightGreen="${esc}[92m"
red="${esc}[31m"
bold="${esc}[1m"
warn="${esc}[41m${esc}[97m"

modulesDefault=(base)
modulesClassic=(base classic)
modulesClassicComposerProject=(base classic-composer classic)
modulesPlatform=(base platform)
modulesLocal=(base local)

phpVersions=(php71 php72 php73 php74)
xdebugPhpVersions=(php71 php70 php72 php73 php74)
mysqlVersions=(55 56 57 8)

function fixHooks()
{
    rm ${SHOPWARE_FOLDER}/.git/hooks/pre-commit
    cd ${SHOPWARE_FOLDER}
    ln -s ../../build/gitHooks/pre-commit .git/hooks/pre-commit
    echo "Hooks fixed"
}

function clearCache()
{
    if [ -d "${SHOPWARE_FOLDER}/var/cache" ]; then
        find ${SHOPWARE_FOLDER}/var/cache -mindepth 1 -maxdepth 1 -type d -exec rm -r {} \;
    fi
}

function checkParameter()
{
    if [[ -z "$SHOPWARE_PROJECT" ]]; then
        echo "Please enter a shopware folder name"
        exit 1
    fi

    if [[ ! -d "$SHOPWARE_FOLDER" ]]; then
        echo "Folder $SHOPWARE_FOLDER does not exists!"
        exit 1
    fi
}

function trim_whitespace() {
    # Function courtesy of http://stackoverflow.com/a/3352015
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}

function get_image()
{
    folder=$1
    var="VHOST_${folder^^}_IMAGE"
    var="${var//-/_}"
    val=${!var}
    SUFFIX=""

    if [[ $XDEBUG_ENABLE == "xdebug" ]]; then
        SUFFIX="-xdebug"
    fi

    if [[ ! -z $val ]]; then
        echo $val
    else
        IMAGE="shyim/shopware-classic-nginx"
        if [[ -f "$2/public/index.php" ]]; then
            IMAGE="shyim/shopware-platform-nginx"
        fi

        echo "${IMAGE}:php${PHP_VERSION}${SUFFIX}"
    fi
}

function get_hosts()
{
    folder=$1
    var="VHOST_${folder^^}_HOSTS"
    var="${var//-/_}"
    val=${!var}

    if [[ ! -z $val ]]; then
        echo $val
    else
        echo "${folder}.dev.localhost"
    fi
}

function get_url()
{
    hosts=$(get_hosts $1)
    host=$(cut -d ',' -f 1 <<< "${hosts}")

    if [[ $USE_SSL_DEFAULT == "true" ]]; then
        echo "https://${host}"
    else
        echo "http://${host}"
    fi
}