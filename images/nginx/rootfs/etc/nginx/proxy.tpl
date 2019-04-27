server {
    listen 80;

    server_name ${PROXY_DOMAIN}.localhost;

    location / {
        proxy_pass http://${PROXY_HOST}:${PROXY_PORT};
    }
}