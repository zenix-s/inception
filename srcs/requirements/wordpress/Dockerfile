FROM debian:bullseye

# Paso 1 - Instalar PHP, utilidades y extensiones necesarias
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
    php7.4-fpm \
    php7.4-mysqli \
    curl \
    mariadb-client \
    wget \
    unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Paso 2 - Crear directorios necesarios
RUN mkdir -p /var/www/html /run/php

# Paso 3 - Copiar configuraciones y scripts
COPY ./conf/php.ini /usr/local/etc/php/conf.d/custom.ini
COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY ./conf/www.conf /usr/local/etc/php-fpm-www.conf

COPY ./tools/wp_setup.sh /usr/local/bin/wp_setup.sh
RUN chmod +x /usr/local/bin/wp_setup.sh

# Paso 4 - Puerto expuesto (informativo)
EXPOSE 9000

# Paso 5 - Comando de arranque
CMD ["bash", "/usr/local/bin/wp_setup.sh"]
