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

function fixHooks()
{
    rm "${SHOPWARE_FOLDER}/.git/hooks/pre-commit"
    cd "${SHOPWARE_FOLDER}" || exit
    ln -s ../../build/gitHooks/pre-commit .git/hooks/pre-commit
    echo "Hooks fixed"
}

function clearCache()
{
    if [ -d "${SHOPWARE_FOLDER}/var/cache" ]; then
        find "${SHOPWARE_FOLDER}/var/cache" -mindepth 1 -maxdepth 1 -type d -exec rm -r {} \;
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
        echo "${folder}.${DEFAULT_DOMAIN}" | tr -d '"'
    fi
}

function get_host()
{
    hosts=$(get_hosts "$1")
    host=$(cut -d ',' -f 1 <<< "${hosts}")
    echo $host
}

function get_url()
{
    host=$(get_host "$1")

    if [[ $USE_SSL_DEFAULT == "true" ]]; then
        echo "https://${host}"
    else
        echo "http://${host}"
    fi
}

function get_cert_name()
{
    folder=$1
    var="VHOST_${folder^^}_CERT_NAME"
    var="${var//-/_}"
    val=${!var}

    if [[ ! -z $val ]]; then
        echo $val
    else
        echo "shared"
    fi
}


function get_serve_folders()
{
    for d in ${CODE_DIRECTORY}/* ; do
        if [[ -d "$d" ]]; then
            if [ -f "$d/public/index.php" ] || [ -f "$d/shopware.php" ]; then
                echo $(basename $d)
            fi
        fi
    done
}

function compose()
{
    docker-compose -f ${DOCKER_COMPOSE_FILE} $@
}

function generate_wildcard_certs()
{
    openssl genrsa -out "${HOME}/.config/swdc/ssl/ca.key" 2048
    openssl req -new -x509 -sha256 -days 20000 -key "${HOME}/.config/swdc/ssl/ca.key" -subj "/C=CN/ST=GD/L=SZ/O=SWDC./CN=SWDC CA" -out "${HOME}/.config/swdc/ssl/ca.crt"
    openssl req -newkey rsa:2048 -nodes -keyout "${HOME}/.config/swdc/ssl/shared.key" -subj "/C=CN/ST=GD/L=SZ/O=SWDC, Inc./CN=*.${DEFAULT_DOMAIN}" -out "${HOME}/.config/swdc/ssl/shared.csr"
    openssl x509 -req -sha256 -extfile <(printf "subjectAltName=DNS:*.${DEFAULT_DOMAIN}") -days 20000 -in "${HOME}/.config/swdc/ssl/shared.csr" -CA "${HOME}/.config/swdc/ssl/ca.crt" -CAkey "${HOME}/.config/swdc/ssl/ca.key" -CAcreateserial -out "${HOME}/.config/swdc/ssl/shared.crt"
}