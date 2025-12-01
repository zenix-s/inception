# DEMONSTRATION - Pasos ordenados para demostrar el proyecto Inception

Este documento explica, en orden y con comandos concretos, las acciones que debes realizar durante la defensa para demostrar que el proyecto cumple los testcases del subject. Está pensado para el evaluador y para que tú sigas los pasos en la VM donde se ejecuta el stack.

Resumen rápido
- Ubicación de los artefactos: `srcs`, `Makefile`, `docker-compose.yml`, `secrets/`, `srcs/requirements/*`.
- Login del proyecto: `serferna` (tu login).
- Objetivo: demostrar que NGINX es el único punto de entrada (puerto 443), TLSv1.2/1.3 está forzado, WordPress se instala automáticamente con `php-fpm`, MariaDB corre en su contenedor, existen dos usuarios DB, y los volúmenes apuntan a `/home/serferna/data/...`. Además, comprobar persistencia tras reinicio.

Antes de empezar (preliminares que debe ejecutar el evaluador)
1. Ejecuta el borrado de recursos Docker para dejar el entorno limpio (requerido por el rubric):
```/dev/null/clean_docker_environment.sh#L1-3
docker stop $(docker ps -qa) 2>/dev/null || true
docker rm $(docker ps -qa) 2>/dev/null || true
docker rmi -f $(docker images -qa) 2>/dev/null || true
docker volume rm $(docker volume ls -q) 2>/dev/null || true
docker network rm $(docker network ls -q) 2>/dev/null || true
```

2. Confirma que `srcs` y `Makefile` existen en el repo (should be at repo root):
```/dev/null/check_files.sh#L1-
Preliminaries

If cheating is suspected, the evaluation stops here. Use the "Cheat" flag to report it. Take this decision calmly, wisely, and please, use this button with caution.
Preliminary tests

    Any credentials, API keys, environment variables must be set inside a .env file during the evaluation. In case any credentials, API keys are available in the git repository and outside of the .env file created during the evaluation, the evaluation stop and the mark is 0.
    Defense can only happen if the evaluated student or group is present. This way everybody learns by sharing knowledge with each other.
    If no work has been submitted (or wrong files, wrong directory, or wrong filenames), the grade is 0, and the evaluation process ends.
    For this project, you have to clone their Git repository on their station.

General instructions

General instructions

    For the entire evaluation process, if you don't know how to check a requirement, or verify anything, the evaluated student has to help you.
    Ensure that all the files required to configure the application are located inside a srcs folder. The srcs folder must be located at the root of the repository.
    Ensure that a Makefile is located at the root of the repository.
    Before starting the evaluation, run this command in the terminal: "docker stop $(docker ps -qa); docker rm $(docker ps -qa); docker rmi -f $(docker images -qa); docker volume rm $(docker volume ls -q); docker network rm $(docker network ls -q) 2>/dev/null"
    Read the docker-compose.yml file. There musn't be 'network: host' in it or 'links:'. Otherwise, the evaluation ends now.
    Read the docker-compose.yml file. There must be 'network(s)' in it. Otherwise, the evaluation ends now.
    Examine the Makefile and all the scripts in which Docker is used. There musn't be '--link' in any of them. Otherwise, the evaluation ends now.
    Examine the Dockerfiles. If you see 'tail -f' or any command run in background in any of them in the ENTRYPOINT section, the evaluation ends now. Same thing if 'bash' or 'sh' are used but not for running a script (e.g, 'nginx & bash' or 'bash').
    If the entrypoint is a script (e.g., ENTRYPOINT ["sh", "my_entrypoint.sh"], ENTRYPOINT ["bash", "my_entrypoint.sh"]), ensure it runs no program
    in background (e.g, 'nginx & bash').
    Examine all the scripts in the repository. Ensure none of them runs an infinite loop. The following are a few examples of prohibited commands: 'sleep infinity', 'tail -f /dev/null', 'tail -f /dev/random'
    Run the Makefile.

Mandatory part

This project consists in setting up a small infrastructure composed of different services using docker compose. Ensure that all the following points are correct.
Project overview

    The evaluated person has to explain to you in simple terms:
        How Docker and docker compose work
        The difference between a Docker image used with docker compose and without docker compose
        The benefit of Docker compared to VMs
        The pertinence of the directory structure required for this project (an example is provided in the subject's PDF file).

Simple setup

    Ensure that NGINX can be accessed by port 443 only. Once done, open the page.
    Ensure that a SSL/TLS certificate is used.
    Ensure that the WordPress website is properly installed and configured (you shouldn't see the WordPress Installation page). To access it, open https://login.42.fr in your browser, where login is the login of the evaluated student. You shouldn't be able to access the site via
    http://login.42.fr. If something doesn't work as expected, the evaluation process ends now.

Docker Basics

    Start by checking the Dockerfiles. There must be one Dockerfile per service. Ensure that the Dockerfiles are not empty files. If it's not the case or if a Dockerfile is missing, the evaluation process ends now.
    Make sure the evaluated student has written their own Dockerfiles and built their own Docker images. Indeed, it is forbidden to use ready-made ones or to use services such as DockerHub.
    Ensure that every container is built from the penultimate stable version of Alpine/Debian. If a Dockerfile does not start with 'FROM alpine:X.X.X' or 'FROM debian:XXXXX', or any other local image, the evaluation process ends now.
    The Docker images must have the same name as their corresponding service. Otherwise, the evaluation process ends now.
    Ensure that the Makefile has set up all the services via docker compose. This means that the containers must have been built using docker compose and that no crash happened. Otherwise, the evaluation process ends.

Docker Network

    Ensure that docker-network is used by checking the docker-compose.yml file. Then run the 'docker network ls' command to verify that a network is visible.
    The evaluated student has to give you a simple explanation of docker-network. If any of the above points is not correct, the evaluation process ends now.

NGINX with SSL/TLS

    Ensure that there is a Dockerfile.
    Using the 'docker compose ps' command, ensure that the container was created (using the flag '-p' is authorized if necessary).
    Try to access the service via http (port 80) and verify that you cannot connect.
    Open https://login.42.fr/ in your browser, where login is the login of the evaluated student. The displayed page must be the configured WordPress website (you shouldn't see the WordPress Installation page).
    The use of a TLS v1.2/v1.3 certificate is mandatory and must be demonstrated. The SSL/TLS certificate doesn't have to be recognized. A self-signed certificate warning may appear. If any of the above points is not clearly explained and correct, the evaluation process ends now.

WordPress with php-fpm and its volume

    Ensure that there is a Dockerfile.
    Ensure that there is no NGINX in the Dockerfile.
    Using the 'docker compose ps' command, ensure that the container was created (using the flag '-p' is authorized if necessary).
    Ensure that there is a Volume. To do so: Run the command 'docker volume ls' then 'docker volume inspect <volume name>'. Verify that the result in the standard output contains the path '/home/login/data/', where login is the login of the evaluated student.
    Ensure that you can add a comment using the available WordPress user.
    Sign in with the administrator account to access the Administration dashboard. The Admin username must not include 'admin' or 'Admin' (e.g., admin, administrator, Admin-login, admin-123, and so forth).
    From the Administration dashboard, edit a page. Verify on the website that the page has been updated. If any of the above points is not correct, the evaluation process ends now.

MariaDB and its volume

    Ensure that there is a Dockerfile.
    Ensure that there is no NGINX in the Dockerfile.
    Using the 'docker compose ps' command, ensure that the container was created (using the flag '-p' is authorized if necessary).
    Ensure that there is a Volume. To do so: Run the command 'docker volume ls' then 'docker volume inspect <volume name>'. Verify that the result in the standard output contains the path '/home/login/data/', where login is the login of the evaluated student.
    The evaluated student must be able to explain you how to login into the database. Verify that the database is not empty. If any of the above points is not correct, the evaluation process ends now.

Persistence!

    This part is pretty straightforward. You have to reboot the virtual machine. Once it has restarted, launch docker compose again. Then, verify that everything is functional, and that both WordPress and MariaDB are configured. The changes you made previously to the WordPress website should still be here. If any of the above points is not correct, the evaluation process ends now.
3
ls -la srcs
ls -la Makefile
```

3. Genera secretos (si el autor ya no los creó) y revisa que `secrets/` existe:
```/dev/null/generate_secrets.sh#L1-2
make secrets
ls -la secrets
```

Despliegue (orden y comandos)
1. Preparar `.env` (variables no secretas)
   - Asegúrate de que `srcs/.env` existe y contiene al menos:
     - `DOMAIN_NAME=serferna.42.fr`
     - `NGINX_PORT=443`
     - `DB_DATABASE`, `DB_USER_NAME`, `DB_SECOND_NAME`, `DB_HOSTNAME=mariadb`
     - `WP_USER`, `WP_EMAIL`, `WP_SECOND_USER`, `WP_SECOND_EMAIL`
   - No pongas contraseñas en `srcs/.env` (se leerán desde `secrets/`).

2. Crear/ajustar `hosts` para pruebas desde la máquina host (o usar 127.0.0.1 si pruebas en la VM)
   - Si pruebas desde la VM y no quieres acceso externo:
```/dev/null/hosts_vm.sh#L1-1
echo "127.0.0.1 serferna.42.fr" | sudo tee -a /etc/hosts
```
   - Si pruebas desde el host y la VM tiene IP `IP_VM`:
```/dev/null/hosts_host.sh#L1-1
echo "IP_VM serferna.42.fr" | sudo tee -a /etc/hosts
```

3. Levantar el stack (desde la raíz del repo)
```/dev/null/make_up.sh#L1-1
make up
```
- Observa el build. Si hay errores, mira logs con `make logs`.

Verificaciones obligatorias (ordenadas y con comandos)
Cada verificación incluye el comando de comprobación y la interpretación esperada.

A. Dockerfiles y versiones base
- Verifica que hay un `Dockerfile` por servicio:
```/dev/null/check_dockerfiles.sh#L1-3
ls -la srcs/requirements/nginx/Dockerfile
ls -la srcs/requirements/wordpress/Dockerfile
ls -la srcs/requirements/mariadb/Dockerfile
```
- Verifica que las `FROM` usan Debian/Alpine con versión explícita (no `:latest`):
```/dev/null/check_from_lines.sh#L1-3
grep -R \"^FROM\" srcs/requirements -n || true
```
Esperado: líneas `FROM debian:bullseye` o `FROM debian:11` (o una penúltima estable) — no `latest`.

B. Imágenes con nombre igual al servicio (no `latest`)
- Comprueba que las imágenes construidas muestran nombres coherentes:
```/dev/null/check_images.sh#L1-3
docker images | grep -E \"nginx|wordpress|mariadb\" || true
```
Esperado: que existan `nginx:<tag>`, `wordpress:<tag>`, `mariadb:<tag>` y que los tags no sean `latest`.

C. Red Docker
- Verifica que existe la red `inception` (o la red declarada en `docker-compose.yml`):
```/dev/null/check_network.sh#L1-2
docker network ls | grep inception || true
docker network inspect inception || true
```
Explicación: pide al evaluado que describa brevemente qué hace una red Docker (aisla tráfico en bridge, permite nombres de servicio DNS internos).

D. NGINX como único punto de entrada y TLS
1. Confirma que solo `nginx` publica puertos al host:
```/dev/null/check_ports.sh#L1-2
docker compose -f srcs/docker-compose.yml ps --services --filter \"status=running\"
docker compose -f srcs/docker-compose.yml port nginx 443 || true
```
2. Probar conexión HTTP (debe fallar) y HTTPS (debe responder):
```/dev/null/test_http_https.sh#L1-4
curl -v http://serferna.42.fr/ --max-time 5 || echo \"HTTP failed as expected\"
curl -vk https://serferna.42.fr/ | head -n 20
```
3. Mostrar que `ssl_protocols` fuerza TLSv1.2/TLSv1.3 en la conf de nginx:
```/dev/null/check_tls_conf.sh#L1-2
grep -n \"ssl_protocols\" srcs/requirements/nginx/conf/default.conf || true
```
Esperado: `ssl_protocols TLSv1.2 TLSv1.3;`

E. WordPress (php-fpm) - instalación automática y volumen
1. Ver contenedor creado y puerto interno 9000 (no publicado):
```/dev/null/check_wp_container.sh#L1-2
docker compose -f srcs/docker-compose.yml ps wordpress
```
2. Verificar `wp-config.php` y que WordPress no pide instalación:
```/dev/null/check_wp_files.sh#L1-2
docker exec -it wordpress bash -lc 'test -f /var/www/html/wp-config.php && echo \"wp-config.php exists\" || echo \"wp-config.php MISSING\"'
```
3. Listar usuarios WordPress con WP-CLI:
```/dev/null/wp_list.sh#L1-1
docker exec -it wordpress bash -lc 'wp user list --allow-root'
```
4. Iniciar sesión en WP Admin:
   - Usa la URL `https://serferna.42.fr/wp-admin` y el usuario `WP_USER` definido en `srcs/.env`.  
   - Contraseña: `secrets/wp_admin_password.txt`.

5. Probar editar una página:
   - Desde el dashboard, edita una página (o crea nueva) y verifica que la modificación aparece en la web.
   - Alternativa con WP-CLI (crear o editar contenido):
```/dev/null/wp_create_page.sh#L1-3
docker exec -it wordpress bash -lc "wp post create --post_type=page --post_title='Demo Page' --post_status=publish --post_content='Demo content' --allow-root"
curl -k https://serferna.42.fr/ | grep -i \"Demo Page\" || true
```

F. MariaDB y su volumen
1. Ver contenedor creado:
```/dev/null/check_mariadb_ps.sh#L1-1
docker compose -f srcs/docker-compose.yml ps mariadb
```
2. Inspeccionar volumen y comprobar que apunta a `/home/serferna/data`:
```/dev/null/check_volumes.sh#L1-3
docker volume ls
docker volume inspect srcs_mariadb_data || docker volume inspect mariadb_data || true
# Si se usan bind-mounts verifica device en docker-compose.yml or with docker volume inspect output
```
Busca en la salida la ruta `/home/serferna/data/mariadb` y `/home/serferna/data/wordpress`.

3. Comprobar usuarios DB y permisos:
```/dev/null/check_db_users.sh#L1-4
docker exec -it mariadb bash -lc 'mysql -u root -p"$(cat /run/secrets/db_root_password)" -e "SELECT User, Host FROM mysql.user;"'
docker exec -it mariadb bash -lc 'mysql -u root -p"$(cat /run/secrets/db_root_password)" -e "SHOW DATABASES;"'
```
Esperado: ver `DB_USER_NAME` y `DB_SECOND_NAME` en la lista, con `Host = %`, y existencia de la base `DB_DATABASE`.

G. Seguridad: no passwords en Dockerfiles
- Revisa que no haya `COPY .env` que meta secretos en imágenes:
```/dev/null/check_env_in_dockerfiles.sh#L1-3
grep -R \"COPY .*\\.env\" -n srcs || true
grep -R \"password\" -n srcs || true
```
Si se encuentra alguna línea preocupante, pedir al evaluado que la explique y corregir.

H. Reinicio y persistencia
1. Reinicia la VM (o reinicia Docker y los contenedores) para comprobar persistencia:
```/dev/null/restart_test.sh#L1-3
# Desde la VM: reinicia
sudo reboot
# Tras reinicio: (en la VM, volver a la carpeta del repo)
make up
# Verificar que los contenidos WordPress y la BBDD persisten:
docker compose -f srcs/docker-compose.yml ps
```
2. Confirmar que la página y los cambios hechos antes del reinicio siguen ahí (abrir `https://serferna.42.fr` y comprobar el contenido).

Pruebas finales que el evaluador debe marcar como OK
- [ ] `srcs` y `Makefile` en la raíz.
- [ ] No uso de `network: host`, `links:` ni `--link`.
- [ ] Dockerfiles por servicio presentes y con `FROM debian:X` o `FROM alpine:X` (no `latest`).
- [ ] `image:` para cada servicio que coincida con el nombre del servicio (o al menos repositorio == servicio) y tag != `latest`.
- [ ] `nginx` expone solo el puerto 443; HTTP (80) no responde desde el host.
- [ ] TLS obliga a TLSv1.2/TLSv1.3 (mostrar `ssl_protocols` y `openssl s_client`).
- [ ] WordPress instalado automáticamente (`wp-config.php` existe) y admin puede loguear (usuario NO contiene `admin`).
- [ ] MariaDB separado, con dos usuarios creados, y volumen apuntando a `/home/serferna/data/mariadb`.
- [ ] Volumen WordPress apunta a `/home/serferna/data/wordpress`.
- [ ] Persistencia tras reboot y cambios en sitio reflejados.

Diagnóstico y arreglos rápidos (si algo falla)
- Si WordPress muestra pantalla de instalación:
  1. Comprueba env vars: `docker exec -it wordpress env | grep -E 'DB_|WP_|DOMAIN'`.
  2. Comprueba que secrets están montados: `docker exec -it wordpress ls -la /run/secrets`.
  3. Ver logs: `docker compose -f srcs/docker-compose.yml logs wordpress --tail=200`.
  4. Si la DB no tiene el usuario esperado, crea usuarios manualmente desde el contenedor `mariadb` (ejemplo):
```/dev/null/create_db_users_manual.sh#L1-12
DB_NAME=$(grep ^DB_DATABASE= srcs/.env | cut -d'=' -f2)
DB_USER=$(grep ^DB_USER_NAME= srcs/.env | cut -d'=' -f2)
DB_SECOND=$(grep ^DB_SECOND_NAME= srcs/.env | cut -d'=' -f2)

docker exec -i mariadb bash -lc "\
mysql -u root -p\"$(cat /run/secrets/db_root_password)\" <<SQL
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$(cat /run/secrets/db_user_password)';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';
CREATE USER IF NOT EXISTS '$DB_SECOND'@'%' IDENTIFIED BY '$(cat /run/secrets/db_second_password)';
GRANT SELECT, INSERT, UPDATE, DELETE ON $DB_NAME.* TO '$DB_SECOND'@'%';
FLUSH PRIVILEGES;
SQL"
```
  5. Luego re-ejecuta `wp_setup.sh` dentro del contenedor `wordpress`:
```/dev/null/run_wp_setup_manual.sh#L1-1
docker exec -it wordpress bash -lc '/usr/local/bin/wp_setup.sh'
```

- Si MariaDB no re-ejecuta el init porque el datadir ya existe:
  - Opción no destructiva: crear usuarios manualmente (ver arriba).
  - Opción destructiva (solo en entorno de prueba): borrar datadir host `/home/serferna/data/mariadb/*` y recrear con `make up`.

Notas para el evaluador (qué pedir al alumno)
- Que explique rápidamente:
  - Qué hace cada `Dockerfile` y por qué usa `php-fpm` en el contenedor WordPress.
  - Por qué NGINX es el único punto de entrada y cómo se fuerza TLS.
  - Dónde están los secretos y por qué no se incorporan en los Dockerfiles.
  - Cómo se asegura la persistencia y la localización de los volúmenes (`/home/serferna/data/...`).
- Pide que ejecute en vivo alguno de los comandos para reproducir un fallo y su corrección (por ejemplo: mostrar `docker compose logs mariadb` y agregar el usuario DB manualmente).

Anexo: comandos útiles de verificación rápida (resumen)
```/dev/null/quick_checks.sh#L1-20
# Estado general
docker compose -f srcs/docker-compose.yml ps

# Logs
docker compose -f srcs/docker-compose.yml logs --tail=200 nginx wordpress mariadb

# Check TLS
openssl s_client -connect serferna.42.fr:443 -tls1_2
openssl s_client -connect serferna.42.fr:443 -tls1_3

# Check wp-config
docker exec -it wordpress bash -lc 'test -f /var/www/html/wp-config.php && echo ok || echo missing'

# Check DB users
docker exec -it mariadb bash -lc 'mysql -u root -p"$(cat /run/secrets/db_root_password)" -e "SELECT User, Host FROM mysql.user;"'

# Check volumes mapping (inspect expected device path)
docker volume inspect srcs_wordpress_data || docker volume inspect srcs_mariadb_data || true
```

Si quieres, genero un `DEMO_SCRIPT.sh` que ejecute las comprobaciones en orden y genere un reporte breve (solo revisión, no aplica cambios). ¿Lo preparo ahora?