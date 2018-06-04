FROM alpine:latest

RUN apk add --no-cache \
	apache-ant \
	mysql-client \
	php7 \
	php7-xml \
	php7-zip \
	php7-phar \
	php7-posix \
	php7-session \
	php7-simplexml \
	php7-openssl \
	php7-pdo \
	php7-pdo_mysql \
	php7-iconv \
	php7-intl \
	php7-json \
	php7-mbstring \
	php7-mysqli \
	php7-dom \
	php7-exif \
	php7-gd \
	php7-gmp \
	php7-bcmath \
	php7-bz2 \
	php7-curl \
	git \
	php7-ctype \
	php7-tokenizer \
	php7-xmlwriter \
	ca-certificates \
	bash \
	curl && \
	update-ca-certificates && \
	curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
	composer global require hirak/prestissimo && \
	mkdir /opt && \
	cd /opt/ && \
	git clone https://github.com/shopwareLabs/sw-cli-tools.git \
    && cd sw-cli-tools \
    && composer install --no-dev \
    && ln -s /opt/sw-cli-tools/bin/sw /usr/local/bin/sw