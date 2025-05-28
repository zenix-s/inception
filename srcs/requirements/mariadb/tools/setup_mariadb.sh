#!/bin/sh

# Initialize database if not already done
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Start MariaDB temporarily to configure it
    mysqld_safe --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock --user=mysql &

    # Wait for MariaDB to start
    while ! mysqladmin ping --silent; do
        sleep 1
    done

    echo "Configuring MariaDB..."

    # Secure installation
    mysql -e "UPDATE mysql.user SET Password=PASSWORD('$MYSQL_ROOT_PASSWORD') WHERE User='root';"
    mysql -e "DELETE FROM mysql.user WHERE User='';"
    mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
    mysql -e "DROP DATABASE IF EXISTS test;"
    mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"

    # Create database and user
    mysql -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    mysql -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
    mysql -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';"
    mysql -e "FLUSH PRIVILEGES;"

    # Stop the temporary MariaDB instance
    mysqladmin shutdown

    echo "MariaDB initialization completed."
fi

echo "Starting MariaDB..."
exec mysqld_safe --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock --user=mysql
