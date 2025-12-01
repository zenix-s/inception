# Paso 1 - Imagen base
FROM debian:bullseye

# Paso 2 - Instalar MariaDB y utilidades
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt install mariadb-server gettext -y && \
    apt-get clean

# Paso 3 - Copiar configuración y scripts al contenedor
COPY requirements/mariadb/conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY .env /etc/mysql/.env
COPY requirements/mariadb/tools/init.sql /etc/mysql/init.temp.sql
COPY requirements/mariadb/tools/substitute_env_vars.sh /usr/local/bin/substitute_env_vars.sh
COPY requirements/mariadb/tools/mariadb_setup.sh /usr/local/bin/mariadb_setup.sh

# Paso 4 - Permisos y directorio runtime
RUN chmod +x /usr/local/bin/*.sh
RUN mkdir /run/mysqld

# Paso 5 - Puerto expuesto (informativo)
EXPOSE 3306

# Paso 6 - Comando de arranque
CMD ["/usr/local/bin/mariadb_setup.sh"]
