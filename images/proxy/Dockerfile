FROM jwilder/nginx-proxy:v0.9.0

COPY unrestricted_client_body_size.conf /etc/nginx/conf.d/unrestricted_client_body_size.conf
COPY proxy.conf /etc/nginx/proxy.conf
COPY --from=ghcr.io/shyim/docker-gen:latest /docker-gen /usr/local/bin/
