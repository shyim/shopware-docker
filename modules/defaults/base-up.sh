#!/usr/bin/env bash

export Platform=$(uname -s)

function create_nginx (){
    while IFS= read -r NAME; do
        d="${CODE_DIRECTORY}/${NAME}"

        hosts=$(get_hosts $NAME)
        certName=$(get_cert_name $NAME)
        echo "  app_${NAME}:" >> ${DOCKER_COMPOSE_FILE}

        IMAGE=$(get_image $NAME $d)
        echo "    image: ${IMAGE}" >> ${DOCKER_COMPOSE_FILE}
        echo "    env_file:" >> ${DOCKER_COMPOSE_FILE}
        echo "      - ${REALDIR}/docker.env" >> ${DOCKER_COMPOSE_FILE}
        echo "      - ~/.config/swdc/env" >> ${DOCKER_COMPOSE_FILE}
        echo "    extra_hosts:" >> ${DOCKER_COMPOSE_FILE}

        for i in ${hosts//,/ }; do
            echo "      ${i}: 127.0.0.1" >> ${DOCKER_COMPOSE_FILE}
        done

        if [[ ${ENABLE_VARNISH} == "false" ]]; then
            echo "    environment:" >> ${DOCKER_COMPOSE_FILE}
            echo "      VIRTUAL_HOST: ${hosts}" >> ${DOCKER_COMPOSE_FILE}
            echo "      CERT_NAME: ${certName}" >> ${DOCKER_COMPOSE_FILE}
            echo "      HTTPS_METHOD: noredirect" >> ${DOCKER_COMPOSE_FILE}
        fi
        echo "    volumes:" >> ${DOCKER_COMPOSE_FILE}
        if [[ ${Platform} != "Linux" ]]; then
            echo "      - ${d}:/var/www/html:cached" >> ${DOCKER_COMPOSE_FILE}
            if [[ ${CACHE_VOLUMES} == "true" ]]; then
                echo "      - ${NAME}_var_cache:/var/www/html/var/cache:delegated" >> ${DOCKER_COMPOSE_FILE}
                echo "      - ${NAME}_web_cache:/var/www/html/web/cache:delegated" >> ${DOCKER_COMPOSE_FILE}
            else
                echo "      - ${CODE_DIRECTORY}/${NAME}/var/cache:/var/www/html/var/cache:delegated" >> ${DOCKER_COMPOSE_FILE}
                echo "      - ${CODE_DIRECTORY}/${NAME}/web/cache:/var/www/html/web/cache:delegated" >> ${DOCKER_COMPOSE_FILE}
            fi
        else
            echo "      - ${d}:/var/www/html" >> ${DOCKER_COMPOSE_FILE}
        fi
    done <<< "$(get_serve_folders)"
}

function create_mysql() {
    echo "  mysql:" >> ${DOCKER_COMPOSE_FILE}
    echo "    image: ${MYSQL_VERSION}" >> ${DOCKER_COMPOSE_FILE}
    echo "    env_file: ${REALDIR}/docker.env" >> ${DOCKER_COMPOSE_FILE}
    if [[ ${EXPOSE_MYSQL_LOCAL} == "true" ]]; then
        echo "    ports:" >> ${DOCKER_COMPOSE_FILE}
        echo "      - 3306:3306" >> ${DOCKER_COMPOSE_FILE}
    fi
    if [[ ${PERSISTENT_DATABASE} == "false" ]]; then
        echo "    tmpfs:" >> ${DOCKER_COMPOSE_FILE}
        echo "      - /var/lib/mysql" >> ${DOCKER_COMPOSE_FILE}
    else
        echo "    volumes:" >> ${DOCKER_COMPOSE_FILE}
        echo "      - ${REALDIR}/mysql-data:/var/lib/mysql:delegated" >> ${DOCKER_COMPOSE_FILE}
    fi

    if [[ ${MYSQL_VERSION} == "shyim/shopware-mysql:8" || ${MYSQL_VERSION} == "ghcr.io/shyim/shopware-docker/mysql:8" || ${MYSQL_VERSION} == "mysql:8"* ]]; then
        echo "    command: [\"mysqld\", \"--default-authentication-plugin=mysql_native_password\"]" >> ${DOCKER_COMPOSE_FILE}
    fi
}

function create_start_mysql() {
  cat <<EOF >> ${DOCKER_COMPOSE_FILE}
  start_mysql:
    image: busybox:latest
    entrypoint:
      - sh
    command: >
      -c "
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

function create_cli () {
    echo "  cli:" >> ${DOCKER_COMPOSE_FILE}
    echo "    image: ghcr.io/shyim/shopware-docker/cli:php${PHP_VERSION}" >> ${DOCKER_COMPOSE_FILE}
    echo "    env_file:" >> ${DOCKER_COMPOSE_FILE}
    echo "      - ${REALDIR}/docker.env" >> ${DOCKER_COMPOSE_FILE}
    echo "      - ${REALDIR}/.env.dist" >> ${DOCKER_COMPOSE_FILE}
    echo "      - ~/.config/swdc/env" >> ${DOCKER_COMPOSE_FILE}
    echo "    environment:" >> ${DOCKER_COMPOSE_FILE}
    echo "      BLACKFIRE_CLIENT_ID: ${BLACKFIRE_SERVER_ID}" >> ${DOCKER_COMPOSE_FILE}
    echo "      BLACKFIRE_CLIENT_TOKEN: ${BLACKFIRE_SERVER_TOKEN}" >> ${DOCKER_COMPOSE_FILE}
    echo "    tty: true" >> ${DOCKER_COMPOSE_FILE}
    echo "    ports:" >> ${DOCKER_COMPOSE_FILE}
    echo "      - 8181:8181" >> ${DOCKER_COMPOSE_FILE}
    echo "      - 8005:8005" >> ${DOCKER_COMPOSE_FILE}
    if [[ ${CODE_FOLDER_CONTENT} ]]; then
        echo "    links:" >> ${DOCKER_COMPOSE_FILE}
        while IFS= read -r NAME; do
            hosts=$(get_hosts $NAME)
            for i in ${hosts//,/ }; do
                echo "      - app_${NAME}:${i}" >> ${DOCKER_COMPOSE_FILE}
            done
        done <<< "$(get_serve_folders)"
        echo "    volumes:" >> ${DOCKER_COMPOSE_FILE}
        echo "      - ${REALDIR}:/opt/swdc/" >> ${DOCKER_COMPOSE_FILE}
        if [[ ${Platform} != "Linux" ]]; then
            echo "      - ${CODE_DIRECTORY}:/var/www/html:cached" >> ${DOCKER_COMPOSE_FILE}

            while IFS= read -r NAME; do
                echo "      - ${CODE_DIRECTORY}/${NAME}/media:/var/www/html/${NAME}/media:cached" >> ${DOCKER_COMPOSE_FILE}
                echo "      - ${CODE_DIRECTORY}/${NAME}/files:/var/www/html/${NAME}/files:cached" >> ${DOCKER_COMPOSE_FILE}
                if [[ ${CACHE_VOLUMES} == "true" ]]; then
                    echo "      - ${NAME}_var_cache:/var/www/html/${NAME}/var/cache:delegated" >> ${DOCKER_COMPOSE_FILE}
                    echo "      - ${NAME}_web_cache:/var/www/html/${NAME}/web/cache:delegated" >> ${DOCKER_COMPOSE_FILE}
                else
                    echo "      - ${CODE_DIRECTORY}/${NAME}/var/cache:/var/www/html/${NAME}/var/cache:delegated" >> ${DOCKER_COMPOSE_FILE}
                    echo "      - ${CODE_DIRECTORY}/${NAME}/web/cache:/var/www/html/${NAME}/web/cache:delegated" >> ${DOCKER_COMPOSE_FILE}
                fi
            done <<< "$(get_serve_folders)"
        else
            echo "      - ${CODE_DIRECTORY}:/var/www/html" >> ${DOCKER_COMPOSE_FILE}
        fi
    fi
}

function create_es () {
    echo "  elastic:" >> ${DOCKER_COMPOSE_FILE}
    echo "    image: blacktop/elasticsearch:${ELASTICSEARCH_VERSION}" >> ${DOCKER_COMPOSE_FILE}
    echo "    environment:" >> ${DOCKER_COMPOSE_FILE}
    echo "      VIRTUAL_HOST: es.localhost" >> ${DOCKER_COMPOSE_FILE}
    echo "      VIRTUAL_PORT: 9200" >> ${DOCKER_COMPOSE_FILE}

    echo "  cerebro:" >> ${DOCKER_COMPOSE_FILE}
    echo "    image: lmenezes/cerebro" >> ${DOCKER_COMPOSE_FILE}
    echo "    expose:" >> ${DOCKER_COMPOSE_FILE}
    echo "     - '9000'" >> ${DOCKER_COMPOSE_FILE}
    echo "    environment:" >> ${DOCKER_COMPOSE_FILE}
    echo "      VIRTUAL_HOST: cerebro.localhost" >> ${DOCKER_COMPOSE_FILE}
    echo "      VIRTUAL_PORT: 9000" >> ${DOCKER_COMPOSE_FILE}
}

function create_redis () {
    echo "  redis:" >> ${DOCKER_COMPOSE_FILE}
    echo "    image: redis:5-alpine" >> ${DOCKER_COMPOSE_FILE}
}

function create_minio () {
    echo "  minio:" >> ${DOCKER_COMPOSE_FILE}
    echo "    image: minio/minio" >> ${DOCKER_COMPOSE_FILE}
    echo "    env_file: ${REALDIR}/docker.env" >> ${DOCKER_COMPOSE_FILE}
    echo "    command: server /data" >> ${DOCKER_COMPOSE_FILE}
    echo "    ports:" >> ${DOCKER_COMPOSE_FILE}
    echo "      - 9000:9000" >> ${DOCKER_COMPOSE_FILE}
    echo "    environment:" >> ${DOCKER_COMPOSE_FILE}
    echo "      VIRTUAL_HOST: s3.localhost" >> ${DOCKER_COMPOSE_FILE}
    echo "      VIRTUAL_PORT: 9000" >> ${DOCKER_COMPOSE_FILE}
}

function create_database_tool () {
    if [[ ${DATABASE_TOOL} == "phpmyadmin" ]]; then
        echo "  phpmyadmin:" >> ${DOCKER_COMPOSE_FILE}
        echo "    image: phpmyadmin/phpmyadmin" >> ${DOCKER_COMPOSE_FILE}
        echo "    env_file:" >> ${DOCKER_COMPOSE_FILE}
        echo "      - ${REALDIR}/docker.env" >> ${DOCKER_COMPOSE_FILE}
        echo "      - ${REALDIR}/phpmyadmin.env" >> ${DOCKER_COMPOSE_FILE}
        echo "    environment:" >> ${DOCKER_COMPOSE_FILE}
        echo "      VIRTUAL_HOST: db.localhost" >> ${DOCKER_COMPOSE_FILE}
    else
        echo "  adminer:" >> ${DOCKER_COMPOSE_FILE}
        echo "    image: ghcr.io/shyim/shopware-docker/adminer" >> ${DOCKER_COMPOSE_FILE}
        echo "    env_file:" >> ${DOCKER_COMPOSE_FILE}
        echo "      - ${REALDIR}/docker.env" >> ${DOCKER_COMPOSE_FILE}
        echo "      - ${REALDIR}/adminer.env" >> ${DOCKER_COMPOSE_FILE}
        echo "    environment:" >> ${DOCKER_COMPOSE_FILE}
        echo "      VIRTUAL_HOST: db.localhost" >> ${DOCKER_COMPOSE_FILE}
        echo "      VIRTUAL_PORT: 8080" >> ${DOCKER_COMPOSE_FILE}
    fi
}

function create_selenium () {
    echo "  selenium:" >> ${DOCKER_COMPOSE_FILE}
    echo "    image: selenium/standalone-chrome:84.0" >> ${DOCKER_COMPOSE_FILE}
    echo "    shm_size: 2g" >> ${DOCKER_COMPOSE_FILE}
    echo "    environment:" >> ${DOCKER_COMPOSE_FILE}
    echo "      DBUS_SESSION_BUS_ADDRESS: /dev/null" >> ${DOCKER_COMPOSE_FILE}

    if [[ ${CODE_FOLDER_CONTENT} ]]; then
        echo "    links:" >> ${DOCKER_COMPOSE_FILE}

        while IFS= read -r NAME; do
            hosts=$(get_hosts $NAME)
            for i in ${hosts//,/ }; do
                echo "      - app_${NAME}:${i}" >> ${DOCKER_COMPOSE_FILE}
            done
        done <<< "$(get_serve_folders)"
    fi
}

function create_cypress () {
    echo "  cypress:" >> ${DOCKER_COMPOSE_FILE}
    echo "    image: cypress/included:3.8.1" >> ${DOCKER_COMPOSE_FILE}
    echo "    shm_size: 2g" >> ${DOCKER_COMPOSE_FILE}
    echo "    environment:" >> ${DOCKER_COMPOSE_FILE}
    echo "      - DISPLAY" >> ${DOCKER_COMPOSE_FILE}
    echo "    volumes:" >> ${DOCKER_COMPOSE_FILE}
    echo "      - ${CODE_DIRECTORY}:/var/www/html" >> ${DOCKER_COMPOSE_FILE}
    echo "      - /tmp/.X11-unix:/tmp/.X11-unix" >> ${DOCKER_COMPOSE_FILE}

    if [[ ${CODE_FOLDER_CONTENT} ]]; then
        echo "    links:" >> ${DOCKER_COMPOSE_FILE}

        while IFS= read -r NAME; do
            hosts=$(get_hosts $NAME)
            for i in ${hosts//,/ }; do
                echo "      - app_${NAME}:${i}" >> ${DOCKER_COMPOSE_FILE}
            done
        done <<< "$(get_serve_folders)"
    fi
}

function create_blackfire () {
    echo "  blackfire:" >> ${DOCKER_COMPOSE_FILE}
    echo "    image: blackfire/blackfire" >> ${DOCKER_COMPOSE_FILE}
    echo "    environment:" >> ${DOCKER_COMPOSE_FILE}
    echo "      BLACKFIRE_SERVER_ID: ${BLACKFIRE_SERVER_ID}" >> ${DOCKER_COMPOSE_FILE}
    echo "      BLACKFIRE_SERVER_TOKEN: ${BLACKFIRE_SERVER_TOKEN}" >> ${DOCKER_COMPOSE_FILE}
}

function create_caching () {
    if [[ ${CODE_FOLDER_CONTENT} ]]; then
        echo "volumes:" >> ${DOCKER_COMPOSE_FILE}

        while IFS= read -r NAME; do
            echo "  ${NAME}_var_cache:" >> ${DOCKER_COMPOSE_FILE}
            echo "    driver: local" >> ${DOCKER_COMPOSE_FILE}
            echo "  ${NAME}_web_cache:" >> ${DOCKER_COMPOSE_FILE}
            echo "    driver: local" >> ${DOCKER_COMPOSE_FILE}
        done <<< "$(get_serve_folders)"
    fi
}

function create_varnish() {
    echo "  varnish:" >> ${DOCKER_COMPOSE_FILE}
    echo "    image: varnish" >> ${DOCKER_COMPOSE_FILE}
    echo "    environment:" >> ${DOCKER_COMPOSE_FILE}
    echo "      VIRTUAL_HOST: '*.sw.shop'" >> ${DOCKER_COMPOSE_FILE}
    echo "      CERT_NAME: shared" >> ${DOCKER_COMPOSE_FILE}
    echo "      HTTPS_METHOD: noredirect" >> ${DOCKER_COMPOSE_FILE}
    echo "    volumes:" >> ${DOCKER_COMPOSE_FILE}
    echo "      - ${REALDIR}/default.vcl:/etc/varnish/default.vcl" >> ${DOCKER_COMPOSE_FILE}
}