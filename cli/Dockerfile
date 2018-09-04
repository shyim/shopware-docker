FROM debian:buster-slim

ENV SHOPWARE_ENV docker

RUN mkdir -p /usr/share/man/man1/ && \
    apt update && apt-get install --no-install-recommends -y \
    openjdk-10-jre-headless \
	ant \
	mariadb-client \
	php7.2-cli \
	php7.2-xml \
	php7.2-zip \
	php7.2-json \
	php7.2-zip \
	php7.2-gmp \
	php7.2-mysql \
	php7.2-sqlite3 \
	php7.2-mbstring \
	php7.2-gd \
	php7.2-curl \
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

RUN composer global require hirak/prestissimo && composer global require bamarni/symfony-console-autocomplete
RUN echo 'eval "$(symfony-autocomplete)"' >> ~/.bash_profile

WORKDIR /var/www/html
