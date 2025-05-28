FROM alpine:3.19

# Install MariaDB
RUN apk update && apk add --no-cache \
    mariadb \
    mariadb-client

# Create necessary directories
RUN mkdir -p /run/mysqld \
    && mkdir -p /var/lib/mysql

# Set permissions
RUN chown -R mysql:mysql /run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql

# Copy initialization script from computer to container
COPY tools/setup_mariadb.sh /setup_mariadb.sh
COPY config/mariadb.cnf /etc/my.cnf.d/mariadb.cnf

# Make script executable
RUN chmod +x /setup_mariadb.sh

# Expose MariaDB port
EXPOSE 3306

# Run setup script
CMD ["/setup_mariadb.sh"]