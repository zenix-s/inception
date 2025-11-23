#!/bin/bash
set -e

# Crear directorio SSL
mkdir -p /etc/nginx/ssl

# Generar certificado SSL autofirmado
if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=ES/ST=Madrid/L=Madrid/O=42/CN=${DOMAIN_NAME}"
fi

# Reemplazar variable en nginx.conf
envsubst '${DOMAIN_NAME}' < /etc/nginx/nginx.conf > /tmp/nginx.conf
mv /tmp/nginx.conf /etc/nginx/nginx.conf

# Iniciar NGINX en primer plano
exec nginx -g 'daemon off;'
