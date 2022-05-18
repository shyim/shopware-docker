#!/usr/bin/env bash

# Coloring/Styling helpers
esc=$(printf '\033')
export esc="${esc}"
export reset="${esc}[0m"
export blue="${esc}[34m"
export green="${esc}[32m"
export lightGreen="${esc}[92m"
export red="${esc}[31m"
export bold="${esc}[1m"
export warn="${esc}[41m${esc}[97m"

export modulesDefault=(base)
export modulesClassic=(base classic)
export modulesClassicComposerProject=(base classic-composer classic)
export modulesPlatform=(base platform)
export modulesLocal=(base local)

function fixHooks() {
  rm "${SHOPWARE_FOLDER}/.git/hooks/pre-commit"
  cd "${SHOPWARE_FOLDER}" || exit 1
  ln -s ../../build/gitHooks/pre-commit .git/hooks/pre-commit
  echo "Hooks fixed"
}

function clearCache() {
  if [ -d "${SHOPWARE_FOLDER}/var/cache" ]; then
    find "${SHOPWARE_FOLDER}/var/cache" -mindepth 1 -maxdepth 1 -type d -exec rm -r {} \;
  fi
}

function checkParameter() {
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
  var="${var#"${var%%[![:space:]]*}"}" # remove leading whitespace characters
  var="${var%"${var##*[![:space:]]}"}" # remove trailing whitespace characters
  echo -n "$var"
}

function get_image() {
  folder=$1
  var="VHOST_${folder^^}_IMAGE"
  var="${var//-/_}"
  val=${!var}
  SUFFIX=""

  if [[ $XDEBUG_ENABLE == "xdebug" ]]; then
    SUFFIX="-xdebug"
  fi

  if [[ -n $val ]]; then
    echo "$val"
  else
    IMAGE="ghcr.io/shyim/shopware-docker/5/nginx"
    if [[ -f "$2/public/index.php" ]]; then
      IMAGE="ghcr.io/shyim/shopware-docker/6/nginx"
    fi

    echo "${IMAGE}:php${PHP_VERSION}${SUFFIX}"
  fi
}

function get_hosts() {
  folder=$1
  var="VHOST_${folder^^}_HOSTS"
  var="${var//-/_}"
  val=${!var}

  if [[ -n $val ]]; then
    echo "$val"
  else
    echo "${folder}.${DEFAULT_DOMAIN}" | tr -d '"'
  fi
}

function get_host() {
  hosts=$(get_hosts "$1")
  host=$(cut -d ',' -f 1 <<<"${hosts}")
  echo "$host"
}

function get_url() {
  host=$(get_host "$1")

  if [[ $USE_SSL_DEFAULT == "true" ]]; then
    PORT=${HTTPS_PORT}
    if [[ ${HTTPS_PORT} == "443" ]]; then
      PORT=""
    else
      PORT=":${PORT}"
    fi

    echo "https://${host}${PORT}"
  else
    PORT=${HTTP_PORT}
    if [[ ${HTTP_PORT} == "80" ]]; then
      PORT=""
    else
      PORT=":${HTTP_PORT}"
    fi

    echo "http://${host}${PORT}"
  fi
}

function get_cert_name() {
  folder=$1
  var="VHOST_${folder^^}_CERT_NAME"
  var="${var//-/_}"
  val=${!var}

  if [[ -n $val ]]; then
    echo "$val"
  else
    echo "shared"
  fi
}

function get_document_root() {
  folder=$1
  var="VHOST_${folder^^}_DOCUMENT_ROOT"
  var="${var//-/_}"
  val=${!var}

  if [[ -n $val ]]; then
    echo "$val"
  else
    ROOT="/var/www/html/${folder}"

    if [[ "$RUN_MODE" == 'local' ]]; then
      ROOT="${CODE_DIRECTORY}/${folder}"
    fi
    if [[ -f "$2/public/index.php" ]]; then
      ROOT="${ROOT}/public"
    fi

    echo "$ROOT"
  fi
}

function get_serve_folders() {
  ignorefile="${CODE_DIRECTORY}/.swdcignore"
  for d in "${CODE_DIRECTORY}"/*; do
    if [[ -d "$d" ]]; then
      if [ -f "$d/public/index.php" ] || [ -f "$d/shopware.php" ] || [ -f "$d/.swdc/service.yml" ]; then
        if [[ ! -f "$ignorefile"  ]] || basename "$d" | grep -qvf "$ignorefile"; then
          basename "$d"
        fi
      fi
    fi
  done
}

function compose() {
  additionalArgs=()
  if [[ -e "${HOME}/.config/swdc/services.yml" ]]; then
    additionalArgs=(-f "${HOME}/.config/swdc/services.yml")
  fi

  docker compose -f "${DOCKER_COMPOSE_FILE}" "${additionalArgs[@]}" "$@"
}

function generate_wildcard_certs() {
  openssl genrsa -out "${HOME}/.config/swdc/ssl/ca.key" 2048
  openssl req -new -x509 -sha256 -days 20000 -key "${HOME}/.config/swdc/ssl/ca.key" -subj "/C=CN/ST=GD/L=SZ/O=SWDC./CN=SWDC CA" -out "${HOME}/.config/swdc/ssl/ca.crt"
  openssl req -newkey rsa:2048 -nodes -keyout "${HOME}/.config/swdc/ssl/shared.key" -subj "/C=CN/ST=GD/L=SZ/O=SWDC, Inc./CN=*.${DEFAULT_DOMAIN}" -out "${HOME}/.config/swdc/ssl/shared.csr"
  openssl x509 -req -sha256 -extfile <(echo -n "subjectAltName=DNS:*.${DEFAULT_DOMAIN}") -days 20000 -in "${HOME}/.config/swdc/ssl/shared.csr" -CA "${HOME}/.config/swdc/ssl/ca.crt" -CAkey "${HOME}/.config/swdc/ssl/ca.key" -CAcreateserial -out "${HOME}/.config/swdc/ssl/shared.crt"
}

function platform_component() {
  NAME=$1

  if [[ -e src/Core/composer.json ]]; then
    echo "src/${NAME}/"
  elif [[ -e vendor/shopware/platform ]]; then
    echo "vendor/shopware/platform/src/${NAME}/"
  else
    echo "vendor/shopware/${NAME,,}/"
  fi
}

function fire_hook() {
  EVENT=$1
  shift

  HOOKS_DIR="$HOME/.config/swdc/hooks"

  if [[ -n $SWDC_IN_DOCKER ]]; then
    HOOKS_DIR="/swdc-cfg/hooks"
  fi

  if [[ -e "$HOOKS_DIR/$EVENT.sh" ]]; then
    # shellcheck disable=SC2145
    echo ". $HOOKS_DIR/$EVENT.sh $@"
  fi
}

function setup_node_version() {
  ADMIN_PATH=$(platform_component Administration)
  NODE_VERSION=$(get_node_version)

  if [[ -n "$NODE_VERSION" ]]; then
    fnm use "$NODE_VERSION" --install-if-missing
  fi
}

function get_node_version() {
  ADMIN_PATH=$(platform_component Administration)
  NODE_VERSION=""

  if [[ -e "$ADMIN_PATH" ]]; then
    NODE_VERSION=$(jq .engines.node "${ADMIN_PATH}Resources/app/administration/package.json" -r | grep -E '\d{1,2}' -o | head -1)

    if [[ "$NODE_VERSION" == "" ]]; then
      NODE_VERSION=$(jq .engines.node "${ADMIN_PATH}Resources/app/administration/package.json" -r | grep -P '\d{1,2}' -o | head -1)
    fi
  fi

  if [[ -z "$NODE_VERSION" ]]; then
    echo "12"
  fi

  echo "$NODE_VERSION"
}
