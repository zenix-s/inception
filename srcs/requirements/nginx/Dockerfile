FROM debian:bullseye

# Paso 1 - Instalar nginx y utilidades
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y nginx openssl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Paso 2 - Copiar scripts y configuración
COPY tools/generate_certs.sh /tmp/generate_certs.sh
COPY conf/default.conf /etc/nginx/sites-available/default

# Paso 3 - Generar certificados y ajustar permisos
RUN chmod +x /tmp/generate_certs.sh && \
    /tmp/generate_certs.sh

RUN chmod -R 755 /var/www/html
RUN chown -R www-data:www-data /var/www/html

# Paso 4 - Puerto expuesto (informativo)
EXPOSE 443

# Paso 5 - Comando de arranque
CMD ["nginx", "-g", "daemon off;"]
