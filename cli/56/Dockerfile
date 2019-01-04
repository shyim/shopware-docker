FROM debian:stretch-slim

ENV SHOPWARE_ENV docker

RUN mkdir -p /usr/share/man/man1/ && \
    apt update && \
    apt install -y curl && \
    curl https://packages.sury.org/php/README.txt | bash && \
    apt update && apt-get install --no-install-recommends -y \
    openjdk-8-jre-headless \
    ant \
    mariadb-client \
    php5.6-cli \
    php5.6-xml \
    php5.6-zip \
    php5.6-json \
    php5.6-zip \
    php5.6-gmp \
    php5.6-mysql \
    php5.6-sqlite3 \
    php5.6-mbstring \
    php5.6-bcmath \
    php5.6-gd \
    php5.6-curl \
    git \
    sudo \
    gpg \
    gpg-agent \
    curl \
    wget \
    nano \
    unzip && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    cd /opt/ && \
    git clone https://github.com/shopwareLabs/sw-cli-tools.git \
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
