#!/usr/bin/env bash

rm -f "${NGINX_VIRTUAL_HOST_DIR}/swdc-*"

CODE_FOLDER_CONTENT="$(ls -A "${CODE_DIRECTORY}")"

if [[ ${CODE_FOLDER_CONTENT} ]]; then

    while IFS= read -r NAME; do
        vhost="${NGINX_VIRTUAL_HOST_DIR}/swdc-${NAME}.conf"

        d="${CODE_DIRECTORY}/${NAME}"
        documentRoot=$(get_document_root "$NAME" "$d")
        hosts=$(get_hosts "$NAME")

        {
          echo "server {"
          echo "    listen ${HTTP_PORT};"
          echo "    index index.php;"
          echo "    server_name ${hosts};"
          echo "    client_max_body_size 128M;"
          echo "    root $documentRoot;"
          echo "    location /recovery/install {"
          echo "        index index.php;"
          echo '        try_files $uri /recovery/install/index.php$is_args$args;'
          echo "    }"
          echo "    location /recovery/update/ {"
          echo "        location /recovery/update/assets {"
          echo "        }"
          echo '        if (!-e $request_filename){'
          echo '            rewrite . /recovery/update/index.php last;'
          echo "        }"
          echo "    }"

          echo "    location / {"
          echo '        try_files $uri /index.php$is_args$args;'
          echo "    }"

          echo "    location ~ \.php$ {"
          echo "        fastcgi_split_path_info ^(.+\.php)(/.+)$;"
          echo "        include fastcgi.conf;"
          echo '        fastcgi_param HTTP_PROXY "";'
          echo "        fastcgi_buffers 8 16k;"
          echo "        fastcgi_buffer_size 32k;"
          echo "        fastcgi_read_timeout 300s;"
          echo "        client_body_buffer_size 128k;"
          echo "        fastcgi_pass 127.0.0.1:9000;"
          echo "    }"


          echo "}"
        } > "${vhost}"
    done <<<"$(get_serve_folders)"
fi

exec ${NGINX_RESTART_CMD}