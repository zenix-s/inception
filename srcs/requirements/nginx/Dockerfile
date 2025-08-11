FROM alpine:3.21

# Install nginx and openssl
RUN apk update && apk upgrade && \
    apk add --no-cache nginx openssl && \
    rm -rf /var/cache/apk/*

# Create directories
RUN mkdir -p /var/www/html /etc/nginx/ssl /run/nginx

# Generate self-signed SSL certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx-selfsigned.key \
    -out /etc/nginx/ssl/nginx-selfsigned.crt \
    -subj "/C=ES/ST=Extremadura/L=Plasencia/O=42School/CN=login.42.fr"

# Copy configuration files
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/entrypoint.sh /entrypoint.sh

# Set permissions
RUN chmod +x /entrypoint.sh

# Expose port
EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]
