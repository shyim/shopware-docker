#!/usr/bin/env sh

if [[ $WSL_XDEBUG_TUNNEL == "true" ]]; then
    # XDEBUG 2
    sed -i 's/xdebug.remote_connect_back=1/xdebug.remote_host=127.0.0.1/' /usr/local/etc/php/conf.d/xdebug.ini
    sed -i 's/xdebug.remote_port=9000/xdebug.remote_port=9050/' /usr/local/etc/php/conf.d/xdebug.ini

    # XDEBUG 3
    sed -i 's/xdebug.discover_client_host=true/xdebug.client_host=127.0.0.1/' /usr/local/etc/php/conf.d/xdebug.ini
    sed -i 's/xdebug.client_port=9000/xdebug.client_port=9050/' /usr/local/etc/php/conf.d/xdebug.ini

    # Prepare supervisord task for socat
    echo '[program:socat]' >> /etc/supervisord.conf
    echo 'command=/usr/bin/socat -d -d TCP4-LISTEN:9050,fork UNIX-CONNECT:/opt/swdc/xdebug.sock' >> /etc/supervisord.conf
    echo 'stdout_logfile=/dev/stderr' >> /etc/supervisord.conf
    echo 'stdout_logfile_maxbytes=0' >> /etc/supervisord.conf
fi

/usr/bin/supervisord -c /etc/supervisord.conf