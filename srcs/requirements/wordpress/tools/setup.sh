#!/bin/bash
set -e

# Leer passwords
WP_ADMIN_PASS=$(cat "$WP_ADMIN_PASSWORD_FILE")
DB_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")

# Esperar a MariaDB con timeout
echo "Esperando a MariaDB..."
TIMEOUT=60
COUNTER=0
until mysqladmin ping -h"mariadb" -u"${MYSQL_USER}" -p"${DB_PASSWORD}" --silent 2>/dev/null; do
    if [ $COUNTER -ge $TIMEOUT ]; then
        echo "ERROR: Timeout esperando a MariaDB"
        exit 1
    fi
    echo "MariaDB no disponible aún (${COUNTER}/${TIMEOUT})..."
    sleep 2
    COUNTER=$((COUNTER + 2))
done
echo "MariaDB está lista!"

cd /var/www/html

# Verificar si WordPress está completamente instalado
if [ ! -f wp-config.php ] || ! wp core is-installed --allow-root 2>/dev/null; then
    echo "Instalando WordPress..."

    # Limpiar instalación parcial si existe
    if [ -f wp-config.php ]; then
        echo "Limpiando instalación incompleta..."
        rm -f wp-config.php
    fi

    # Descargar si no está descargado
    if [ ! -f wp-load.php ]; then
        echo "Descargando archivos de WordPress..."
        wp core download --allow-root
    fi

    # Configurar
    echo "Configurando WordPress..."
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root \
        --force

    # Instalar
    echo "Instalando WordPress en la base de datos..."
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASS}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    # Crear segundo usuario
    echo "Creando usuario adicional..."
    if ! wp user get "${WP_USER}" --allow-root 2>/dev/null; then
        wp user create \
            "${WP_USER}" \
            "${WP_USER_EMAIL}" \
            --user_pass="${WP_USER_PASSWORD}" \
            --role=author \
            --allow-root
    fi

    echo "✓ WordPress instalado correctamente"
else
    echo "✓ WordPress ya está instalado"
fi

# Permisos
chown -R www-data:www-data /var/www/html

# Iniciar PHP-FPM
echo "Iniciando PHP-FPM..."
exec php-fpm7.4 -F
