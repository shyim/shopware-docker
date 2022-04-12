#!/usr/bin/env bash

Platform=$(uname -s)
export Platform="${Platform}"

function create_nginx() {
  if [[ ${CODE_FOLDER_CONTENT} ]]; then

    while IFS= read -r NAME; do
      d="${CODE_DIRECTORY}/${NAME}"

      hosts=$(get_hosts "$NAME")
      certName=$(get_cert_name "$NAME")
      documentRoot=$(get_document_root "$NAME" "$d")
      echo "  app_${NAME}:" >>"${DOCKER_COMPOSE_FILE}"

      if [[ -e "$d/.swdc/service.yml" ]]; then
        sed 's/^/    /' "$d/.swdc/service.yml" >> "${DOCKER_COMPOSE_FILE}"
      else
        if [[ -e "$d/.swdc/Dockerfile" ]]; then
          echo "    build: ${d}/.swdc/" >>"${DOCKER_COMPOSE_FILE}"
        else
          IMAGE=$(get_image "$NAME" "$d")
          echo "    image: ${IMAGE}" >>"${DOCKER_COMPOSE_FILE}"
        fi

        {
          echo "    env_file:"
          echo "      - ${REALDIR}/docker.env"
          echo "      - ~/.config/swdc/env"
          echo "    networks:"
          echo "      default:"
          echo "        aliases:"
        } >>"${DOCKER_COMPOSE_FILE}"

        for i in ${hosts//,/ }; do
          echo "          - ${i}" >>"${DOCKER_COMPOSE_FILE}"
        done

        {
          echo "    environment:"
          echo "      APP_DOCUMENT_ROOT: ${documentRoot}"
        } >>"${DOCKER_COMPOSE_FILE}"

        if [[ ${ENABLE_VARNISH} == "false" ]]; then
          {
            echo "      VIRTUAL_HOST: ${hosts}"
            echo "      CERT_NAME: ${certName}"
            echo "      HTTPS_METHOD: noredirect"
          } >>"${DOCKER_COMPOSE_FILE}"
        fi
        {
          echo "    volumes:"
          echo "      - ${REALDIR}:/opt/swdc/"
        } >>"${DOCKER_COMPOSE_FILE}"
          if [[ -e "${d}/php.ini" ]]; then
            echo "      - ${d}/php.ini:/usr/local/etc/php/conf.d/swdc-custom.ini" >>"${DOCKER_COMPOSE_FILE}"
          fi

          echo "      - ${CODE_DIRECTORY}:/var/www/html" >>"${DOCKER_COMPOSE_FILE}"
      fi
    done <<<"$(get_serve_folders)"
  fi
}

function create_mysql() {
  {
    echo "  mysql:"
    echo "    image: ${MYSQL_VERSION}"
    echo "    env_file: ${REALDIR}/docker.env"
  } >>"${DOCKER_COMPOSE_FILE}"
  if [[ ${EXPOSE_MYSQL_LOCAL} == "true" ]]; then
    {
      echo "    ports:"
      echo "      - 3306:3306"
    } >>"${DOCKER_COMPOSE_FILE}"
  fi
  if [[ ${PERSISTENT_DATABASE} == "false" ]]; then
    {
      echo "    tmpfs:"
      echo "      - /var/lib/mysql"
    } >>"${DOCKER_COMPOSE_FILE}"
  fi

  if [[ ${PERSISTENT_DATABASE} == "true" || -e "$HOME/.config/swdc/mysql.conf" ]]; then
    echo "    volumes:" >> "${DOCKER_COMPOSE_FILE}"
  fi

  if [[ ${PERSISTENT_DATABASE} == "true" ]]; then
    echo "      - ${MYSQL_DATA_DIR:-$REALDIR}/mysql-data:/var/lib/mysql:delegated" >> "${DOCKER_COMPOSE_FILE}"
  fi

  if [[ -e "$HOME/.config/swdc/mysql.conf" ]]; then
    echo "      - $HOME/.config/swdc/mysql.conf:/etc/mysql/conf.d/zz-override.cnf" >> "${DOCKER_COMPOSE_FILE}"
  fi

  if [[ ${MYSQL_VERSION} == "shyim/shopware-mysql:8" || ${MYSQL_VERSION} == "ghcr.io/shyim/shopware-docker/mysql:8" || ${MYSQL_VERSION} == "mysql:8"* ]]; then
    echo "    command: [\"mysqld\", \"--default-authentication-plugin=mysql_native_password\"]" >>"${DOCKER_COMPOSE_FILE}"
  fi
}

function create_start_mysql() {
  cat <<EOF >>"${DOCKER_COMPOSE_FILE}"
  start_mysql:
    image: busybox:latest
    volumes:
      - nvm_cache:/nvm
      - tool_cache:/tmp/swdc-tool-cache
    entrypoint:
      - sh
    command: >
      -c "
        chown 1000:1000 /nvm
        chown 1000:1000 /tmp/swdc-tool-cache
        while !(nc -z mysql 3306)
        do
          echo -n '.'
          sleep 1
        done;
        echo 'database ready!'
      "
    depends_on:
      - mysql
EOF
}

function create_cli() {
  {
    echo "  cli:"
    echo "    image: ghcr.io/shyim/shopware-docker/cli:php${PHP_VERSION}"
    echo "    env_file:"
    echo "      - ${REALDIR}/docker.env"
    echo "      - ${REALDIR}/.env.dist"
    echo "      - ~/.config/swdc/env"
    echo "    tty: true"
    echo "    ports:"
    echo "      - 8181:8181"
    echo "      - 8005:8005"
    echo "      - 9998:9998"
    echo "      - 9999:9999"
    echo "    volumes:"
    echo "      - ${REALDIR}:/opt/swdc/"
    echo "      - nvm_cache:/nvm"
    echo "      - tool_cache:/tmp/swdc-tool-cache"
    echo "      - ~/.config/swdc/:/swdc-cfg"
  } >>"${DOCKER_COMPOSE_FILE}"

  if [[ ${CODE_FOLDER_CONTENT} ]]; then
    echo "      - ${CODE_DIRECTORY}:/var/www/html" >>"${DOCKER_COMPOSE_FILE}"
  fi
}

function create_es() {
  {
    echo "  elastic:"
    echo "    image: ${ELASTICSEARCH_IMAGE}"
    echo "    environment:"
    echo "      VIRTUAL_HOST: es.${DEFAULT_SERVICES_DOMAIN}"
    echo "      VIRTUAL_PORT: 9200"
    echo "      discovery.type: single-node"

    if [[ "${ELASTICSEARCH_IMAGE}" == *"amazon" ]]; then
      echo "      opendistro_security.ssl.http.enabled: 'false'"
    fi

    if [[ "${ELASTICSEARCH_IMAGE}" == *"opensearchproject"* ]]; then
      echo "      plugins.security.disabled: 'true'"
    fi

    echo "  kibana:"
    echo "    image: ${KIBANA_IMAGE}"
    echo "    links:"
    echo "      - elastic:elasticsearch"
    echo "    environment:"
    echo "      VIRTUAL_HOST: kibana.${DEFAULT_SERVICES_DOMAIN}"
    echo "      VIRTUAL_PORT: 5601"

    if [[ "${ELASTICSEARCH_IMAGE}" == *"amazon" ]]; then
      echo "      ELASTICSEARCH_URL: http://elastic:9200"
      echo "      ELASTICSEARCH_HOSTS: http://elastic:9200"
    fi

    if [[ "${ELASTICSEARCH_IMAGE}" == *"opensearchproject"* ]]; then
      echo "      ELASTICSEARCH_URL: http://elastic:9200"
      echo "      OPENSEARCH_HOSTS: '[\"http://elastic:9200\"]'"
      echo "      plugins.security.disabled: 'true'"
    fi
  } >>"${DOCKER_COMPOSE_FILE}"
}

function create_redis() {
  {
    echo "  redis:"
    echo "    image: redis:5-alpine"
  } >>"${DOCKER_COMPOSE_FILE}"
}

function create_minio() {
  {
    echo "  minio:"
    echo "    image: minio/minio"
    echo "    env_file: ${REALDIR}/docker.env"
    echo "    command: server /data --console-address=':9015'"
    echo "    ports:"
    echo "      - 9010:9000"
    echo "      - 9015:9015"
    echo "    environment:"
    echo "      VIRTUAL_HOST: s3.${DEFAULT_SERVICES_DOMAIN}"
    echo "      VIRTUAL_PORT: 9015"
  } >>"${DOCKER_COMPOSE_FILE}"
}

function create_database_tool() {
  if [[ ${DATABASE_TOOL} == "phpmyadmin" ]]; then
    {
      echo "  phpmyadmin:"
      echo "    image: phpmyadmin/phpmyadmin"
      echo "    env_file:"
      echo "      - ${REALDIR}/docker.env"
      echo "      - ${REALDIR}/phpmyadmin.env"
      echo "    environment:"
      echo "      VIRTUAL_HOST: db.${DEFAULT_SERVICES_DOMAIN}"
    } >>"${DOCKER_COMPOSE_FILE}"
  else
    {
      echo "  adminer:"
      echo "    image: ghcr.io/shyim/shopware-docker/adminer"
      echo "    env_file:"
      echo "      - ${REALDIR}/docker.env"
      echo "      - ${REALDIR}/adminer.env"
      echo "    environment:"
      echo "      VIRTUAL_HOST: db.${DEFAULT_SERVICES_DOMAIN}"
      echo "      VIRTUAL_PORT: 8080"
    } >>"${DOCKER_COMPOSE_FILE}"
  fi
}

function create_selenium() {
  cat <<EOF | tee -a "${DOCKER_COMPOSE_FILE}" > /dev/null
  selenium:
    image: selenium/standalone-chrome:84.0
    shm_size: 2g
    environment:
      DBUS_SESSION_BUS_ADDRESS: /dev/null
      SCREEN_WIDTH: 1920
      SCREEN_HEIGHT: 1080
      SCREEN_DPI: 72
    ports:
      - 5900:5900
EOF

  if [[ ${CODE_FOLDER_CONTENT} ]]; then
    echo "    links:" >>"${DOCKER_COMPOSE_FILE}"

    while IFS= read -r NAME; do
      hosts=$(get_hosts "$NAME")
      for i in ${hosts//,/ }; do
        echo "      - app_${NAME}:${i}" >>"${DOCKER_COMPOSE_FILE}"
      done
    done <<<"$(get_serve_folders)"
  fi
}

function create_cypress() {
  {
    echo "  cypress-backup-proxy:"
    echo "    image: ghcr.io/shyim/shopware-docker/cypress-backup-proxy:latest"
    echo "    env_file:"
    echo "      - ${REALDIR}/docker.env"
    echo "    volumes:"
    echo "      - /var/run/docker.sock:/var/run/docker.sock"
  } >>"${DOCKER_COMPOSE_FILE}"
}

function create_blackfire() {
  {
    echo "  blackfire:"
    echo "    image: blackfire/blackfire:2"
    echo "    environment:"
    echo "      BLACKFIRE_SERVER_ID: ${BLACKFIRE_SERVER_ID}"
    echo "      BLACKFIRE_SERVER_TOKEN: ${BLACKFIRE_SERVER_TOKEN}"
    echo "      BLACKFIRE_DISABLE_LEGACY_PORT: 1"
  } >>"${DOCKER_COMPOSE_FILE}"
}

function create_varnish() {
  {
    echo "  varnish:"
    echo "    image: varnish"
    echo "    environment:"
    echo "      VIRTUAL_HOST: '*.${DEFAULT_DOMAIN}'"
    echo "      CERT_NAME: shared"
    echo "      HTTPS_METHOD: noredirect"
    echo "    volumes:"
    echo "      - ${REALDIR}/default.vcl:/etc/varnish/default.vcl"
  } >>"${DOCKER_COMPOSE_FILE}"
}
