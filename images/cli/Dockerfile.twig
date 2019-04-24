FROM debian:stretch-slim as builder

RUN mkdir -p /usr/share/man/man1/ && \
    apt-get update && \
    apt-get install --no-install-recommends -y curl wget ca-certificates git make && \
    curl https://packages.sury.org/php/README.txt | bash && \
    apt-get update && apt-get install -y \
    php{{ phpVersion }}-dev -y && \
    cd /root && \
    git clone https://github.com/krakjoe/pcov.git && \
    cd pcov && \
    phpize && \
    ./configure --enable-pcov && \
    make

FROM debian:stretch-slim

ENV SHOPWARE_ENV docker

RUN mkdir -p /usr/share/man/man1/ && \
    apt-get update && \
    apt-get install --no-install-recommends -y curl wget ca-certificates && \
    curl https://packages.sury.org/php/README.txt | bash && \
    apt-get update && apt-get install --no-install-recommends -y \
    patch \
    mariadb-client \
    php{{ phpVersion }}-cli \
    php{{ phpVersion }}-xml \
    php{{ phpVersion }}-zip \
    php{{ phpVersion }}-json \
    php{{ phpVersion }}-zip \
    php{{ phpVersion }}-gmp \
    php{{ phpVersion }}-mysql \
    php{{ phpVersion }}-sqlite3 \
    php{{ phpVersion }}-mbstring \
    php{{ phpVersion }}-bcmath \
    php{{ phpVersion }}-gd \
    php{{ phpVersion }}-curl \
    php{{ phpVersion }}-soap \
    php{{ phpVersion }}-intl \
    git \
    sudo \
    gpg \
    gpg-agent \
    curl \
    wget \
    nano \
    ssmtp \
    unzip \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && useradd dev \
    && mkdir /home/dev \
    && chown -R dev: /home/dev \
    && curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash - \
    && apt-get install nodejs -y \
    && echo "extension=/usr/php-pcov.so" >> /etc/php/{{ phpVersion }}/cli/php.ini \
    && echo "pcov.enabled = 0" >> /etc/php/{{ phpVersion }}/cli/php.ini

COPY --from=builder /root/pcov/modules/pcov.so /usr/php-pcov.so

ENV HOME /home/dev
USER dev

COPY rootfs/ /

RUN composer global require hirak/prestissimo

WORKDIR /var/www/html
