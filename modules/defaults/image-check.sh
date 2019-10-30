function check_xdebug(){
    if [[ "${1}" == "xdebug" ]]; then
        [[ " $xdebugPhpVersions " =~ " php${PHP_VERSION} " ]] && echo "${PHP_VERSION}" || echo "${PHP_VERSION}-xdebug"
    fi
}
function check_php(){
    [[ " $phpVersions " =~ " php${PHP_VERSION} " ]] && echo "${red}unsupported PHP_VERSION${reset}" && exit 1 fi
}
