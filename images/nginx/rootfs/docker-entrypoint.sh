#!/bin/sh

export PROXY_DOMAIN="mail"
export PROXY_HOST="smtp"
export PROXY_PORT="8025"
cat /etc/nginx/proxy.tpl | envsubst '\$PROXY_DOMAIN \$PROXY_HOST \$PROXY_PORT' > /etc/nginx/sites-enabled/mail.conf

if [ "$DATABASE_TOOL" == "adminer" ]
then
    export PROXY_DOMAIN="db"
    export PROXY_HOST="adminer"
    export PROXY_PORT="8080"
    cat /etc/nginx/proxy.tpl | envsubst '\$PROXY_DOMAIN \$PROXY_HOST \$PROXY_PORT' > /etc/nginx/sites-enabled/db.conf
fi

if [ "$DATABASE_TOOL" == "phpmyadmin" ]
then
    export PROXY_DOMAIN="db"
    export PROXY_HOST="phpmyadmin"
    export PROXY_PORT="80"
    cat /etc/nginx/proxy.tpl | envsubst '\$PROXY_DOMAIN \$PROXY_HOST \$PROXY_PORT' > /etc/nginx/sites-enabled/db.conf
fi

if [ "$ENABLE_ELASTICSEARCH" == "true" ]
then
    export PROXY_DOMAIN="cerebro"
    export PROXY_HOST="cerebro"
    export PROXY_PORT="9000"
    cat /etc/nginx/proxy.tpl | envsubst '\$PROXY_DOMAIN \$PROXY_HOST \$PROXY_PORT' > /etc/nginx/sites-enabled/cerebro.conf

    export PROXY_DOMAIN="es"
    export PROXY_HOST="elastic"
    export PROXY_PORT="9200"
    cat /etc/nginx/proxy.tpl | envsubst '\$PROXY_DOMAIN \$PROXY_HOST \$PROXY_PORT' > /etc/nginx/sites-enabled/es.conf
fi

exec "$@"