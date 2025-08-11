FROM alpine:3.21

# Install PHP-FPM and required extensions
RUN apk update && apk upgrade && \
    apk add --no-cache \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-curl \
    php82-dom \
    php82-exif \
    php82-fileinfo \
    php82-mbstring \
    php82-openssl \
    php82-xml \
    php82-zip \
    php82-phar \
    php82-tokenizer \
    php82-session \
    php82-ctype \
    php82-iconv \
    php82-simplexml \
    php82-xmlwriter \
    curl \
    wget \
    su-exec && \
    rm -rf /var/cache/apk/*

# Create directories and PHP symlink
RUN mkdir -p /var/www/html /run/php && \
    ln -sf /usr/bin/php82 /usr/bin/php

# Download and install WP-CLI
RUN curl -L -o wp-cli.phar https://github.com/wp-cli/wp-cli/releases/download/v2.8.1/wp-cli-2.8.1.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Copy configuration files
COPY config/www.conf /etc/php82/php-fpm.d/www.conf
COPY config/php.ini /etc/php82/php.ini
COPY tools/entrypoint.sh /entrypoint.sh

# Set permissions
RUN chmod +x /entrypoint.sh && \
    chown -R nobody:nobody /var/www/html /run/php

# Expose port
EXPOSE 9000

ENTRYPOINT ["/entrypoint.sh"]
