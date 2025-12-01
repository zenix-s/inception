#!/bin/bash
# helper script: only prints the steps required to deploy the project on a VM
# El script NO realiza acciones (no instala ni modifica nada). Solo muestra instrucciones.
set -e

cat <<'INSTRUCTIONS'
INCEPTION - Instrucciones de despliegue en una MÁQUINA VIRTUAL
--------------------------------------------------------------

Resumen rápido:
  - Esta guía asume una VM basada en Debian/Ubuntu.
  - Debes ejecutar estos pasos en la VM donde se desplegará el stack.
  - No se realizan cambios automáticos: sigue las instrucciones manualmente.

1) Preparar la VM
   - Actualiza paquetes:
     sudo apt-get update && sudo apt-get upgrade -y

2) Instalar Docker y Docker Compose plugin (comandos de referencia)
   - Instala dependencias y el repositorio oficial de Docker, luego:
     sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
   - Añade tu usuario al grupo docker para evitar sudo en los comandos docker:
     sudo usermod -aG docker $USER
   - Cierra sesión y vuelve a iniciar sesión para aplicar el grupo.

3) Copiar o clonar el repositorio en la VM
   - Coloca el proyecto en la VM (ejemplo):
     cd ~
     git clone <tu_repo_url> inception
     cd inception

4) Generar secretos (no incluir contraseñas en Dockerfiles)
   - Desde la raíz del repo:
     make secrets
   - Se crearán archivos en el directorio 'secrets':
     db_root_password.txt
     db_user_password.txt
     db_second_password.txt
     wp_admin_password.txt
     wp_second_password.txt

5) Preparar variables no-secretas en srcs/.env
   - Crea/edita `srcs/.env` con valores como:
     DOMAIN_NAME=serferna.42.fr
     NGINX_PORT=443
     DB_DATABASE=wordpress
     DB_USER_NAME=site_owner          # NO usar admin/administrator
     DB_SECOND_NAME=wp_reader
     DB_HOSTNAME=mariadb
     WP_USER=serferna_admin_user      # NO usar admin ni variantes
     WP_EMAIL=you@example.com
     WP_SECOND_USER=wp_subscriber
     WP_SECOND_EMAIL=other@example.com
   - No pongas contraseñas en .env; las contraseñas deben estar en 'secrets/'.

6) Comprobar /etc/hosts para el dominio de pruebas
   - Mapea el dominio a la IP de la VM (desde el equipo donde pruebas o dentro de la VM):
     # Reemplaza 192.168.XX.YYY por la IP real de la VM
     echo "192.168.XX.YYY serferna.42.fr" | sudo tee -a /etc/hosts

7) Crear directorios de datos y permisos (Makefile lo hace)
   - Por defecto el Makefile usa /home/serferna/data.
   - Si tu login es distinto, usa:
     make DATA_DIR=/home/<tu_login>/data up
   - Para crear directorios y levantar los servicios:
     make up
   - Si necesitas que el Makefile use otra ruta:
     make DATA_DIR=/home/<tu_login>/data up

8) Comprobaciones post-arranque
   - Ver contenedores:
     docker compose -f srcs/docker-compose.yml ps
   - Ver logs:
     make logs
     docker compose -f srcs/docker-compose.yml logs mariadb
     docker compose -f srcs/docker-compose.yml logs wordpress
     docker compose -f srcs/docker-compose.yml logs nginx

9) Verificar TLS y que solo 443 esté expuesto
   - Probar TLSv1.2:
     openssl s_client -connect serferna.42.fr:443 -tls1_2
   - Probar TLSv1.3:
     openssl s_client -connect serferna.42.fr:443 -tls1_3
   - Probar HTTPS (ignorar certificado autofirmado con -k):
     curl -vk https://serferna.42.fr/

10) Verificar WordPress y usuarios
   - Accede desde un navegador a: https://serferna.42.fr
   - Comprobar usuarios con WP-CLI dentro del contenedor wordpress:
     docker exec -it wordpress bash
     wp user list --allow-root
     exit

11) Verificar usuarios en MariaDB
   - Entra al contenedor mariadb:
     docker exec -it mariadb bash
   - Comprueba usuarios (usa la contraseña root desde secrets):
     mysql -u root -p"$(cat /run/secrets/db_root_password)" -e "SELECT User, Host FROM mysql.user;"
   - Comprueba que existen DB_USER_NAME y DB_SECOND_NAME

12) Firewall (recomendado)
   - Permitir solo 443/tcp (ejemplo con ufw):
     sudo ufw allow 443/tcp
     sudo ufw deny 80/tcp
     sudo ufw enable

13) Limpieza / reinicio
   - Parar y eliminar contenedores (sin volúmenes):
     make down
   - Limpieza total (incluye volúmenes y datos locales):
     make fclean

Notas importantes y comprobaciones de cumplimiento
   - Asegúrate de que las imágenes base en los Dockerfiles sean la penúltima versión estable de Debian/Alpine según el enunciado (no usar :latest).
   - No incluyas contraseñas en los Dockerfiles ni copies .env dentro de la imagen.
   - El nombre del usuario administrador de WordPress NO puede contener 'admin' ni variantes.
   - NGINX debe ser el único servicio expuesto al exterior y usar TLSv1.2/TLSv1.3.
   - Genera y mantiene los secretos en el directorio local 'secrets' (no los subas a Git).

Ayuda adicional
   - Si necesitas un ejemplo de `srcs/.env` listo para ajustar, o quieres que genere un `srcs/.env.example`, revisa el repositorio y crea el archivo manualmente siguiendo las claves listadas arriba.

FIN DE LAS INSTRUCCIONES
INSTRUCTIONS
