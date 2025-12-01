#!/bin/bash

# Paso 1 - Cargar secretos desde archivos de Docker secrets
if [ -f /run/secrets/db_root_password ]; then
    export DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
fi
if [ -f /run/secrets/db_user_password ]; then
    export DB_USER_PASSWORD=$(cat /run/secrets/db_user_password)
fi
# Cargar secreto para el segundo usuario de la BBDD (opcional pero recomendado)
if [ -f /run/secrets/db_second_password ]; then
    export DB_SECOND_PASSWORD=$(cat /run/secrets/db_second_password)
fi

# Verificar que las variables críticas están presentes (evitar ejecutar init con valores vacíos)
MISSING=0
if [ -z "${DB_DATABASE:-}" ]; then
    echo "[!] Missing required env: DB_DATABASE" >&2
    MISSING=1
fi
if [ -z "${DB_USER_NAME:-}" ]; then
    echo "[!] Missing required env: DB_USER_NAME" >&2
    MISSING=1
fi
if [ -z "${DB_USER_PASSWORD:-}" ]; then
    echo "[!] Missing required secret: DB_USER_PASSWORD" >&2
    MISSING=1
fi
if [ -z "${DB_SECOND_NAME:-}" ]; then
    echo "[!] Missing required env: DB_SECOND_NAME" >&2
    MISSING=1
fi
if [ -z "${DB_SECOND_PASSWORD:-}" ]; then
    echo "[!] Missing required secret: DB_SECOND_PASSWORD" >&2
    MISSING=1
fi
if [ $MISSING -eq 1 ]; then
    echo "[!] One or more required environment variables/secrets are missing. Aborting init." >&2
    exit 1
fi

# Paso 2 - Sustituir variables en el archivo de inicialización SQL
# Se delega a la utilidad que reemplaza variables de entorno en /etc/mysql/init.sql
bash /usr/local/bin/substitute_env_vars.sh

# Paso 3 - Inicializar el directorio de datos de MariaDB si está vacío
# Comprobamos la presencia de las tablas del sistema para determinar si hay que inicializar.
if [ ! -d "/var/lib/mysql/mysql" ]; then
    # Inicializar las tablas del sistema de MariaDB en el datadir especificado.
    # mysql_install_db --user=mysql --datadir=/var/lib/mysql --auth-root-authentication-method=normal
    #   -> mysql_install_db es la utilidad para inicializar el directorio de datos.
    #   -> --user=mysql indica que los archivos serán propiedad del usuario mysql.
    #   -> --datadir especifica la ubicación del directorio de datos.
    #   -> --auth-root-authentication-method=normal configura el método de autenticación del root como normal (contraseña).
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --auth-root-authentication-method=normal
fi

# Paso 4 - Iniciar MariaDB en segundo plano para poder ejecutar tareas de configuración
# Se lanza el daemon en background para permitir la ejecución de comandos mysql/mysqladmin.
# mysqld &
#   -> mysqld es el comando para iniciar el servidor MariaDB.
#   -> & al final indica que se ejecute en segundo plano.
mysqld &

# Paso 5 - Esperar hasta que MariaDB acepte conexiones
# Reintentamos ping hasta que el servidor responda por el socket.
while ! mysqladmin ping --silent; do
    sleep 1
done

# Paso 6 - Ejecutar SQL inicial solo si no se ha ejecutado previamente
# Utilizamos un archivo bandera para evitar volver a aplicar el init SQL en arranques posteriores.
INITIALIZED_FLAG="/var/lib/mysql/INITIALIZED_FLAG"
INIT_SQL="/etc/mysql/init.sql"
if [ ! -f "$INITIALIZED_FLAG" ]; then
    mysql -u root < "$INIT_SQL"
    touch "$INITIALIZED_FLAG"
fi

# Paso 7 - Detener el servidor temporalmente para que el contenedor pueda arrancar luego en primer plano
# Se usa la contraseña root si está disponible; si no, intentamos sin -p.
mysqladmin -u root -p"$DB_ROOT_PASSWORD" shutdown

# Paso 8 - Ejecutar MariaDB en primer plano como proceso principal del contenedor
# Reemplazamos el shell por el proceso del servidor para que Docker gestione el PID 1.
exec mysqld
