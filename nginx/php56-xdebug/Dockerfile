FROM shyim/shopware-nginx:php56

RUN docker-php-ext-enable xdebug
RUN echo 'xdebug.remote_enable=1' > /usr/local/etc/php/conf.d/ext-xdebug.ini && \
    echo 'xdebug.remote_autostart=0' >> /usr/local/etc/php/conf.d/ext-xdebug.ini && \
    echo 'xdebug.remote_connect_back=1' >> /usr/local/etc/php/conf.d/ext-xdebug.ini && \
    echo 'xdebug.remote_port=9000' >> /usr/local/etc/php/conf.d/ext-xdebug.ini && \
    echo 'xdebug.remote_log=/tmp/xdebug.log' >> /usr/local/etc/php/conf.d/ext-xdebug.ini && \
    echo 'xdebug.idekey=PHPSTORM' >> /usr/local/etc/php/conf.d/ext-xdebug.ini