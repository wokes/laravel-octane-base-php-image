# Accepted values: 8.1 - 8.0
ARG PHP_VERSION=8.1

FROM php:${PHP_VERSION}-cli-alpine

LABEL maintainer="Seyed Morteza Ebadi <seyed.me720@gmail.com>"

ARG TZ=UTC

ENV DEBIAN_FRONTEND=noninteractive \
    TERM=xterm-color

ENV ROOT=/var/www/html
WORKDIR $ROOT

SHELL ["/bin/bash", "-eou", "pipefail", "-c"]

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

RUN apt-get update; \
    apt-get upgrade -yqq; \
    pecl -q channel-update pecl.php.net; \
    apt-get install -yqq --no-install-recommends --show-progress \
          apt-utils \
          gnupg \
          gosu \
          git \
          curl \
          wget \
          libcurl4-openssl-dev \
          ca-certificates \
          supervisor \
          libmemcached-dev \
          libz-dev \
          libbrotli-dev \
          libpq-dev \
          libjpeg-dev \
          libpng-dev \
          libfreetype6-dev \
          libssl-dev \
          libwebp-dev \
          libmcrypt-dev \
          libonig-dev \
          libzip-dev zip unzip \
          libargon2-1 \
          libidn2-0 \
          libpcre2-8-0 \
          libpcre3 \
          libxml2 \
          libzstd1 \
          procps

###########################################
# pdo_mysql
###########################################

RUN docker-php-ext-install pdo_mysql;

###########################################
# zip
###########################################

RUN docker-php-ext-configure zip && docker-php-ext-install zip;

###########################################
# mbstring
###########################################

RUN docker-php-ext-install mbstring;

###########################################
# GD
###########################################

RUN docker-php-ext-configure gd \
            --prefix=/usr \
            --with-jpeg \
            --with-webp \
            --with-freetype \
    && docker-php-ext-install gd;

###########################################
# OPcache
###########################################

ARG INSTALL_OPCACHE=true

RUN if [ ${INSTALL_OPCACHE} = true ]; then \
      docker-php-ext-install opcache; \
  fi

###########################################
# PHP Redis
###########################################

ARG INSTALL_PHPREDIS=true

RUN if [ ${INSTALL_PHPREDIS} = true ]; then \
      pecl -q install -o -f redis \
      && rm -rf /tmp/pear \
      && docker-php-ext-enable redis; \
  fi

###########################################
# PCNTL
###########################################

ARG INSTALL_PCNTL=true

RUN if [ ${INSTALL_PCNTL} = true ]; then \
      docker-php-ext-install pcntl; \
  fi

###########################################
# BCMath
###########################################

ARG INSTALL_BCMATH=true

RUN if [ ${INSTALL_BCMATH} = true ]; then \
      docker-php-ext-install bcmath; \
  fi

###########################################
# RDKAFKA
###########################################

ARG INSTALL_RDKAFKA=true

RUN if [ ${INSTALL_RDKAFKA} = true ]; then \
      apt-get install -yqq --no-install-recommends --show-progress librdkafka-dev \
      && pecl -q install -o -f rdkafka \
      && docker-php-ext-enable rdkafka; \
  fi

###########################################
# OpenSwoole/Swoole extension
###########################################

ARG INSTALL_SWOOLE=true
ARG SERVER=openswoole

RUN if [ ${INSTALL_SWOOLE} = true ]; then \
      apt-get install -yqq --no-install-recommends --show-progress libc-ares-dev \
      && pecl -q install -o -f -D 'enable-openssl="yes" enable-http2="yes" enable-swoole-curl="yes" enable-mysqlnd="yes" enable-cares="yes"' ${SERVER} \
      && docker-php-ext-enable ${SERVER}; \
    fi

###########################################################################
# Human Language and Character Encoding Support
###########################################################################

ARG INSTALL_INTL=true

RUN if [ ${INSTALL_INTL} = true ]; then \
      apt-get install -yqq --no-install-recommends --show-progress zlib1g-dev libicu-dev g++ \
      && docker-php-ext-configure intl \
      && docker-php-ext-install intl; \
  fi

###########################################
# Memcached
###########################################

ARG INSTALL_MEMCACHED=false

RUN if [ ${INSTALL_MEMCACHED} = true ]; then \
      pecl -q install -o -f memcached && docker-php-ext-enable memcached; \
  fi

###########################################
# MySQL Client
###########################################

ARG INSTALL_MYSQL_CLIENT=true

RUN if [ ${INSTALL_MYSQL_CLIENT} = true ]; then \
      apt-get install -yqq --no-install-recommends --show-progress default-mysql-client; \
  fi

###########################################
# pdo_pgsql
###########################################

ARG INSTALL_PDO_PGSQL=false

RUN if [ ${INSTALL_PDO_PGSQL} = true ]; then \
      docker-php-ext-install pdo_pgsql; \
  fi

###########################################
# pgsql
###########################################

ARG INSTALL_PGSQL=false

RUN if [ ${INSTALL_PGSQL} = true ]; then \
      docker-php-ext-install pgsql; \
  fi

###########################################
# pgsql client and postgis
###########################################

ARG INSTALL_PG_CLIENT=false
ARG INSTALL_POSTGIS=false

RUN if [ ${INSTALL_PG_CLIENT} = true ]; then \
        apt-get install -yqq gnupg \
        && . /etc/os-release \
        && echo "deb http://apt.postgresql.org/pub/repos/apt $VERSION_CODENAME-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
        && curl -sL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
        && apt-get update -yqq \
        && apt-get install -yqq --no-install-recommends --show-progress postgresql-client-12 postgis; \
        if [ ${INSTALL_POSTGIS} = true ]; then \
          apt-get install -yqq --no-install-recommends --show-progress postgis; \
        fi \
        && apt-get purge -yqq gnupg; \
  fi

COPY . .

RUN ls
