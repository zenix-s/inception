#Makefile

NAME	=	inception
DATA_DIR ?= /home/serferna/data
SECRETS_DIR ?= secrets

all: up

setup_dirs:
	sudo mkdir -p $(DATA_DIR)/wordpress
	sudo chown -R 101:101 $(DATA_DIR)/wordpress
	sudo chmod 755 $(DATA_DIR)/wordpress
	sudo mkdir -p $(DATA_DIR)/mariadb
	sudo chown -R 101:101 $(DATA_DIR)/mariadb
	sudo chmod 750 $(DATA_DIR)/mariadb

up:	setup_dirs secrets
	docker compose -f srcs/docker-compose.yml up -d --build

down:
	docker compose -f srcs/docker-compose.yml down --remove-orphans

logs:
	docker compose -f srcs/docker-compose.yml logs -f

re: down up

clean:
	docker compose -f srcs/docker-compose.yml down --remove-orphans
	docker image prune -f

secrets:
	@echo "Generando secretos de Docker..."
	@mkdir -p $(SECRETS_DIR)
	@openssl rand -base64 12 | tr -d /=+ | cut -c -12 > $(SECRETS_DIR)/db_root_password.txt
	@openssl rand -base64 12 | tr -d /=+ | cut -c -12 > $(SECRETS_DIR)/db_user_password.txt
	@openssl rand -base64 12 | tr -d /=+ | cut -c -12 > $(SECRETS_DIR)/db_second_password.txt
	@openssl rand -base64 12 | tr -d /=+ | cut -c -12 > $(SECRETS_DIR)/wp_admin_password.txt
	@openssl rand -base64 12 | tr -d /=+ | cut -c -12 > $(SECRETS_DIR)/wp_second_password.txt
	@echo "Secretos generados y guardados en el directorio '$(SECRETS_DIR)'"

secrets-status:
	@echo "Estado de los secretos de Docker:"
	@if [ -d "$(SECRETS_DIR)" ]; then \
		echo "El directorio de secretos existe"; \
		for file in db_root_password.txt db_user_password.txt db_second_password.txt wp_admin_password.txt wp_second_password.txt; do \
			if [ -f "$(SECRETS_DIR)/$$file" ]; then \
				echo "$$file existe"; \
			else \
				echo "$$file falta"; \
			fi; \
		done; \
	else \
		echo "Falta el directorio de secretos"; \
	fi

secrets-clean:
	@echo "Eliminando los secretos generados..."
	@rm -f $(SECRETS_DIR)/db_root_password.txt $(SECRETS_DIR)/db_user_password.txt $(SECRETS_DIR)/db_second_password.txt
	@rm -f $(SECRETS_DIR)/wp_admin_password.txt $(SECRETS_DIR)/wp_second_password.txt
	@echo "Secretos eliminados"

fclean: secrets-clean
	docker compose -f srcs/docker-compose.yml down --volumes --remove-orphans
	docker container prune -f
	docker image prune -af
	docker volume prune -f
	sudo rm -rf $(DATA_DIR)/
	docker volume rm srcs_mariadb_data srcs_wordpress_data || true

volumes:
	docker volume ls
	docker volume inspect srcs_mariadb_data
	docker volume inspect srcs_wordpress_data

status:
	@echo "Contenedores Docker:"
	@docker ps -a --filter name=nginx --filter name=wordpress --filter name=mariadb

	@echo "\nVolúmenes Docker:"
	@docker volume ls | grep -E 'mariadb_data|wordpress_data' || echo "No se encontraron volúmenes"

	@echo "\nRutas de los volúmenes Docker:"
	@echo "MariaDB:    $(DATA_DIR)/mariadb"
	@echo "WordPress:  $(DATA_DIR)/wordpress"
	@sudo ls -l $(DATA_DIR)/

	@echo "\nRed Docker:"
	@docker network ls | grep inception || echo "No se encontró la red"

	@make secrets-status

help:
	@echo "Comandos del Makefile de Inception:"
	@echo "  make up         - Iniciar todos los contenedores"
	@echo "  make down       - Detener todos los contenedores"
	@echo "  make re         - Reiniciar todos los contenedores"
	@echo "  make logs       - Mostrar los logs de los contenedores"
	@echo "  make clean      - Eliminar contenedores e imágenes"
	@echo "  make fclean     - Limpieza total (contenedores, volúmenes, datos)"
	@echo "  make status     - Mostrar el estado del proyecto"
	@echo "  make volumes    - Mostrar información de los volúmenes"
	@echo "  make secrets    - Generar secretos de Docker"
	@echo "  make secrets-status - Comprobar el estado de los secretos"
	@echo "  make secrets-clean  - Eliminar los secretos generados"
	@echo "Comandos de Docker:"
	@echo "  docker ps       - Listar contenedores en ejecución"
	@echo "  docker images   - Listar imágenes de Docker"
	@echo "  docker volume ls - Listar volúmenes de Docker"
	@echo "  docker network ls - Listar redes de Docker"
	@echo "  docker exec -it <container> bash - Acceder a la terminal del contenedor"
