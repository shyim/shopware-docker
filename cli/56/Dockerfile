FROM php:5.6-cli

ENV SHOPWARE_ENV docker

RUN mkdir -p /usr/share/man/man1/ && apt-get update && apt-get install --no-install-recommends -y \
        ant \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        zip \
        zlib1g-dev \
        unzip \
        git \
        mysql-client \
        wget \
        git \
        nano \
        wget \
        curl \
        curl \
        libcurl4-gnutls-dev \
        tar \
        sudo \
        gpg \
        gpg-agent \
        nano \
        libxml2 \
        libxml2-dev \
        libssl-dev \
    && docker-php-ext-install -j$(nproc) iconv mbstring zip ftp soap curl pdo pdo_mysql mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && rm -rf /var/lib/apt/lists/* \
    && echo "date.timezone = 'Europe/Berlin'" >> /usr/local/etc/php/php.ini \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && cd /opt/ \
    && git clone https://github.com/shopwareLabs/sw-cli-tools.git \
    && cd sw-cli-tools \
    && composer install --no-dev \
    && ln -s /opt/sw-cli-tools/bin/sw /usr/local/bin/sw \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && useradd dev \
    && mkdir /home/dev \
    && chown -R dev: /home/dev \
    && curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash - \
    && apt-get install nodejs -y

ENV HOME /home/dev
USER dev

RUN composer global require hirak/prestissimo

WORKDIR /var/www/html
