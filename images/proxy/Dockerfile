FROM jwilder/nginx-proxy

COPY unrestricted_client_body_size.conf /etc/nginx/conf.d/unrestricted_client_body_size.conf
COPY proxy.conf /etc/nginx/proxy.conf
COPY --from=ghcr.io/shyim/docker-gen:latest /docker-gen /usr/local/bin/
