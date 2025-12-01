#!/bin/bash

# Paso 1 - Crear directorio para los certificados si no existe
mkdir -p /etc/nginx/ssl

# Paso 2 - Generar certificado autofirmado válido 365 días
openssl req -x509 -nodes -days 365 \
    -subj "/C=ES/ST=Madrid/L=Madrid/O=Inception/CN=serferna.42.fr" \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt
