#!/bin/bash
set -e

# Leer passwords desde secrets
DB_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
DB_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")

# Crear directorio para socket si no existe
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Verificar si la base de datos ya está inicializada
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Inicializando base de datos..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Iniciar MariaDB temporalmente
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    pid="$!"

    # Esperar a que MariaDB esté lista
    echo "Esperando a que MariaDB esté lista..."
    for i in {30..0}; do
        if mysqladmin ping --silent 2>/dev/null; then
            break
        fi
        sleep 1
    done

    if [ "$i" = 0 ]; then
        echo "Error: MariaDB no se inició correctamente"
        exit 1
    fi

    echo "MariaDB lista. Configurando base de datos..."

    # Configurar base de datos (root NO tiene password aún)
    mysql -u root << EOF
-- Configurar root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Crear base de datos y usuario para WordPress
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    echo "Base de datos configurada correctamente."

    # Detener MariaDB temporal
    mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown

    echo "Esperando a que MariaDB se detenga..."
    wait "$pid"
    echo "MariaDB detenida. Iniciando en modo normal..."
else
    echo "Base de datos ya inicializada. Saltando configuración..."
fi

# Iniciar MariaDB en primer plano (modo normal)
echo "Iniciando MariaDB..."
exec mysqld --user=mysql --datadir=/var/lib/mysql
