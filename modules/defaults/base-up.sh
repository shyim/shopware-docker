#!/usr/bin/env bash

Platform=$(uname -s)
export Platform="${Platform}"

function create_nginx() {
  while IFS= read -r NAME; do
    d="${CODE_DIRECTORY}/${NAME}"

    hosts=$(get_hosts "$NAME")
    certName=$(get_cert_name "$NAME")
    echo "  app_${NAME}:" >>"${DOCKER_COMPOSE_FILE}"

    IMAGE=$(get_image "$NAME" "$d")
    {
      echo "    image: ${IMAGE}"
      echo "    env_file:"
      echo "      - ${REALDIR}/docker.env"
      echo "      - ~/.config/swdc/env"
      echo "    extra_hosts:"
    } >>"${DOCKER_COMPOSE_FILE}"

    for i in ${hosts//,/ }; do
      echo "      ${i}: 127.0.0.1" >>"${DOCKER_COMPOSE_FILE}"
    done

    if [[ ${ENABLE_VARNISH} == "false" ]]; then
      {
        echo "    environment:"
        echo "      VIRTUAL_HOST: ${hosts}"
        echo "      CERT_NAME: ${certName}"
        echo "      HTTPS_METHOD: noredirect"
      } >>"${DOCKER_COMPOSE_FILE}"
    fi
    {
      echo "    volumes:"
      echo "      - ${REALDIR}:/opt/swdc/"
    } >>"${DOCKER_COMPOSE_FILE}"
    if [[ ${Platform} != "Linux" ]]; then
      echo "      - ${d}:/var/www/html:cached" >>"${DOCKER_COMPOSE_FILE}"
      if [[ ${CACHE_VOLUMES} == "true" ]]; then
        {
          echo "      - ${NAME}_web_cache:/var/www/html/web/cache:delegated"
          echo "      - ${NAME}_var_cache:/var/www/html/var/cache:delegated"
        } >>"${DOCKER_COMPOSE_FILE}"
      else
        {
          echo "      - ${CODE_DIRECTORY}/${NAME}/var/cache:/var/www/html/var/cache:delegated"
          echo "      - ${CODE_DIRECTORY}/${NAME}/web/cache:/var/www/html/web/cache:delegated"
        } >>"${DOCKER_COMPOSE_FILE}"
      fi
    else
      echo "      - ${d}:/var/www/html" >>"${DOCKER_COMPOSE_FILE}"
    fi
  done <<<"$(get_serve_folders)"
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
  else
    {
      echo "    volumes:"
      echo "      - ${REALDIR}/mysql-data:/var/lib/mysql:delegated"
    } >>"${DOCKER_COMPOSE_FILE}"
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
    entrypoint:
      - sh
    command: >
      -c "
        chown 1000:1000 /nvm
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
    echo "    environment:"
    echo "      BLACKFIRE_CLIENT_ID: ${BLACKFIRE_SERVER_ID}"
    echo "      BLACKFIRE_CLIENT_TOKEN: ${BLACKFIRE_SERVER_TOKEN}"
    echo "    tty: true"
    echo "    ports:"
    echo "      - 8181:8181"
    echo "      - 8005:8005"
    echo "      - 9998:9998"
    echo "      - 9999:9999"
  } >>"${DOCKER_COMPOSE_FILE}"
  if [[ ${CODE_FOLDER_CONTENT} ]]; then
    echo "    links:" >>"${DOCKER_COMPOSE_FILE}"
    while IFS= read -r NAME; do
      hosts=$(get_hosts "$NAME")
      for i in ${hosts//,/ }; do
        echo "      - app_${NAME}:${i}" >>"${DOCKER_COMPOSE_FILE}"
      done
    done <<<"$(get_serve_folders)"

    {
      echo "    volumes:"
      echo "      - ${REALDIR}:/opt/swdc/"
      echo "      - nvm_cache:/nvm"
    } >>"${DOCKER_COMPOSE_FILE}"
    if [[ ${Platform} != "Linux" ]]; then
      echo "      - ${CODE_DIRECTORY}:/var/www/html:cached" >>"${DOCKER_COMPOSE_FILE}"

      while IFS= read -r NAME; do
        {
          echo "      - ${CODE_DIRECTORY}/${NAME}/media:/var/www/html/${NAME}/media:cached"
          echo "      - ${CODE_DIRECTORY}/${NAME}/files:/var/www/html/${NAME}/files:cached"
        } >>"${DOCKER_COMPOSE_FILE}"

        if [[ ${CACHE_VOLUMES} == "true" ]]; then
          {
            echo "      - ${NAME}_var_cache:/var/www/html/${NAME}/var/cache:delegated"
            echo "      - ${NAME}_web_cache:/var/www/html/${NAME}/web/cache:delegated"
          } >>"${DOCKER_COMPOSE_FILE}"
        else
          {
            echo "      - ${CODE_DIRECTORY}/${NAME}/var/cache:/var/www/html/${NAME}/var/cache:delegated"
            echo "      - ${CODE_DIRECTORY}/${NAME}/web/cache:/var/www/html/${NAME}/web/cache:delegated"
          } >>"${DOCKER_COMPOSE_FILE}"
        fi
      done <<<"$(get_serve_folders)"
    else
      echo "      - ${CODE_DIRECTORY}:/var/www/html" >>"${DOCKER_COMPOSE_FILE}"
    fi
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
    echo "    command: server /data"
    echo "    ports:"
    echo "      - 9000:9000"
    echo "    environment:"
    echo "      VIRTUAL_HOST: s3.${DEFAULT_SERVICES_DOMAIN}"
    echo "      VIRTUAL_PORT: 9000"
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
  {
    echo "  selenium:"
    echo "    image: selenium/standalone-chrome:84.0"
    echo "    shm_size: 2g"
    echo "    environment:"
    echo "      DBUS_SESSION_BUS_ADDRESS: /dev/null"
  } >>"${DOCKER_COMPOSE_FILE}"

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
    echo "  cypress:"
    echo "    image: cypress/included:5.6.0"
    echo "    shm_size: 2g"
    echo "    environment:"
    echo "      - DISPLAY"
    echo "    volumes:"
    echo "      - ${CODE_DIRECTORY}:/var/www/html"
    echo "      - /tmp/.X11-unix:/tmp/.X11-unix"
  } >>"${DOCKER_COMPOSE_FILE}"

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

function create_blackfire() {
  {
    echo "  blackfire:"
    echo "    image: blackfire/blackfire"
    echo "    environment:"
    echo "      BLACKFIRE_SERVER_ID: ${BLACKFIRE_SERVER_ID}"
    echo "      BLACKFIRE_SERVER_TOKEN: ${BLACKFIRE_SERVER_TOKEN}"
  } >>"${DOCKER_COMPOSE_FILE}"
}

function create_caching() {
  if [[ ${CODE_FOLDER_CONTENT} ]]; then
    while IFS= read -r NAME; do
      {
        echo "  ${NAME}_var_cache:"
        echo "    driver: local"
        echo "  ${NAME}_web_cache:"
        echo "    driver: local"
      } >>"${DOCKER_COMPOSE_FILE}"
    done <<<"$(get_serve_folders)"
  fi
}

function create_varnish() {
  {
    echo "  varnish:"
    echo "    image: varnish"
    echo "    environment:"
    echo "      VIRTUAL_HOST: '*.sw.shop'"
    echo "      CERT_NAME: shared"
    echo "      HTTPS_METHOD: noredirect"
    echo "    volumes:"
    echo "      - ${REALDIR}/default.vcl:/etc/varnish/default.vcl"
  } >>"${DOCKER_COMPOSE_FILE}"
}
