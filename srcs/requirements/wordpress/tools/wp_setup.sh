#!/bin/bash

# Paso 1 - Cargar secretos desde Docker secrets (si existen)
if [ -f /run/secrets/db_user_password ]; then
    export DB_USER_PASSWORD=$(cat /run/secrets/db_user_password)
fi
if [ -f /run/secrets/wp_admin_password ]; then
    export WP_PASSWORD=$(cat /run/secrets/wp_admin_password)
fi
if [ -f /run/secrets/wp_second_password ]; then
    export WP_SECOND_PASSWORD=$(cat /run/secrets/wp_second_password)
fi

# Paso 2 - Si WordPress ya está instalado, iniciar php-fpm en primer plano y salir
if [ -f /var/www/html/wp-config.php ]; then
    echo "[+] WordPress ya está instalado. Saltando configuración inicial."
    php-fpm7.4 -F
    exit 0
fi

# Paso 3 - Copiar configuración de pool PHP-FPM
cp /usr/local/etc/php-fpm-www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Paso 4 - Descargar WP-CLI si no existe
if [ ! -f /usr/local/bin/wp ]; then
  cd /usr/local/bin
  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar
  mv wp-cli.phar wp
fi

# Paso 5 - Preparar el directorio web
mkdir -p /var/www/html
cd /var/www/html

# Paso 6 - Descargar e instalar WordPress
wp core download --allow-root
wp config create \
  --dbname="$DB_DATABASE" \
  --dbuser="$DB_USER_NAME" \
  --dbpass="$DB_USER_PASSWORD" \
  --dbhost="$DB_HOSTNAME" \
  --allow-root

# Paso 7 - Crear usuario administrador
wp core install \
  --url="$DOMAIN_NAME" \
  --title="serferna's Inception" \
  --admin_user="$WP_USER" \
  --admin_password="$WP_PASSWORD" \
  --admin_email="$WP_EMAIL" \
  --skip-email \
  --allow-root

# Paso 8 - Crear segundo usuario no administrador
wp user create "$WP_SECOND_USER" "$WP_SECOND_EMAIL" \
  --user_pass="$WP_SECOND_PASSWORD" \
  --role=subscriber \
  --allow-root

# Paso 9 - Lanzar php-fpm en primer plano
php-fpm7.4 -F
