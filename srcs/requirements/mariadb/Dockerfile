FROM alpine:3.21

# Install MariaDB
RUN apk update && apk upgrade && \
    apk add --no-cache mariadb mariadb-client && \
    rm -rf /var/cache/apk/*

# Create directories
RUN mkdir -p /var/lib/mysql /run/mysqld

# Copy configuration and scripts
COPY config/my.cnf /etc/my.cnf
COPY tools/entrypoint.sh /entrypoint.sh

# Set permissions
RUN chmod +x /entrypoint.sh && \
    chown -R mysql:mysql /var/lib/mysql /run/mysqld

# Expose port
EXPOSE 3306

USER mysql

ENTRYPOINT ["/entrypoint.sh"]
