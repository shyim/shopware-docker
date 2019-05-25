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

phpVersions=(php71 php72 php73)
xdebugPhpVersions=(php71 php70 php72)
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