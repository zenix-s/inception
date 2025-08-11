#!/bin/sh

# Read passwords from environment variables
DB_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
DB_PASSWORD=$MYSQL_PASSWORD

# Initialize database if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."

    # Create log directory and files
    mkdir -p /var/log/mysql
    touch /var/log/mysql/error.log
    touch /var/log/mysql/slow.log
    chown -R mysql:mysql /var/log/mysql

    # Initialize the database
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Start MariaDB temporarily to configure it
    mysqld_safe --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock &

    # Wait for MariaDB to start
    until mysqladmin ping -S /run/mysqld/mysqld.sock --silent; do
        echo "Waiting for MariaDB to start..."
        sleep 1
    done

    # Configure the database
    mysql -S /run/mysqld/mysqld.sock <<EOF
-- Set root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASSWORD';

-- Remove anonymous users
DELETE FROM mysql.user WHERE User='';

-- Remove remote root access
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Create WordPress database
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create WordPress user
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';

-- Remove test database
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Flush privileges
FLUSH PRIVILEGES;
EOF

    # Stop the temporary MariaDB instance
    mysqladmin -S /run/mysqld/mysqld.sock shutdown

    echo "MariaDB initialization completed."
else
    # Ensure log directory exists even if DB is already initialized
    mkdir -p /var/log/mysql
    touch /var/log/mysql/error.log
    touch /var/log/mysql/slow.log
    chown -R mysql:mysql /var/log/mysql
fi

echo "Starting MariaDB..."
exec mysqld --user=mysql --console
