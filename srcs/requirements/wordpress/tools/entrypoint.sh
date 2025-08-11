#!/bin/sh

# Read passwords from environment variables
WP_ADMIN_PASSWORD=$WP_ADMIN_PASSWORD
WP_USER_PASSWORD=$WP_USER_PASSWORD
DB_PASSWORD=$MYSQL_PASSWORD

# Create log directory
mkdir -p /var/log/php81

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
until wp db check --allow-root --path=/var/www/html; do
    echo "Waiting for database connection..."
    sleep 3
done

# Download WordPress if not already present
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Setting up WordPress..."

    # Download WordPress
    wp core download --allow-root --path=/var/www/html

    # Create wp-config.php
    wp config create \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbpass=$DB_PASSWORD \
        --dbhost=mariadb:3306 \
        --allow-root \
        --path=/var/www/html

    # Install WordPress
    wp core install \
        --url="https://$DOMAIN_NAME" \
        --title="Inception WordPress Site" \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL \
        --allow-root \
        --path=/var/www/html

    # Create additional user
    wp user create \
        $WP_USER \
        $WP_USER_EMAIL \
        --user_pass=$WP_USER_PASSWORD \
        --role=author \
        --allow-root \
        --path=/var/www/html

    echo "WordPress setup completed."
fi

echo "Starting PHP-FPM..."
exec php-fpm81 -F
