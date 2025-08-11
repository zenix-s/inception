FROM alpine:3.21

# Install PHP-FPM and required extensions
RUN apk update && apk upgrade && \
    apk add --no-cache \
    php81 \
    php81-fpm \
    php81-mysqli \
    php81-json \
    php81-curl \
    php81-dom \
    php81-exif \
    php81-fileinfo \
    php81-mbstring \
    php81-openssl \
    php81-xml \
    php81-zip \
    php81-phar \
    php81-tokenizer \
    php81-session \
    php81-ctype \
    php81-iconv \
    php81-simplexml \
    php81-xmlwriter \
    curl \
    wget && \
    rm -rf /var/cache/apk/*

# Create directories
RUN mkdir -p /var/www/html /run/php

# Download and install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/v2.8.1/bin/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Copy configuration files
COPY config/www.conf /etc/php81/php-fpm.d/www.conf
COPY config/php.ini /etc/php81/php.ini
COPY tools/entrypoint.sh /entrypoint.sh

# Set permissions
RUN chmod +x /entrypoint.sh && \
    chown -R nobody:nobody /var/www/html /run/php

# Expose port
EXPOSE 9000

USER nobody

ENTRYPOINT ["/entrypoint.sh"]
