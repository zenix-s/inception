#Makefile

NAME	=	inception

all: up

setup_dirs:
	sudo mkdir -p /home/serferna/data/wordpress
	sudo chown -R 101:101 /home/serferna/data/wordpress
	sudo chmod 755 /home/serferna/data/wordpress
	sudo mkdir -p /home/serferna/data/mariadb
	sudo chown -R 101:101 /home/serferna/data/mariadb
	sudo chmod 750 /home/serferna/data/mariadb

up:	setup_dirs
	docker compose -f srcs/docker-compose.yml up -d --build

down:
	docker compose -f srcs/docker-compose.yml down --remove-orphans

logs:
	docker compose -f srcs/docker-compose.yml logs -f

re: down up

clean:
	docker compose -f srcs/docker-compose.yml down --remove-orphans
	docker image prune -f

fclean:
	docker compose -f srcs/docker-compose.yml down --volumes --remove-orphans
	docker container prune -f
	docker image prune -af
	docker volume prune -f
	sudo rm -rf /home/serferna/data/
	docker volume rm srcs_mariadb_data srcs_wordpress_data || true

volumes:
	docker volume ls
	docker volume inspect srcs_mariadb_data
	docker volume inspect srcs_wordpress_data

status:
	@echo "🟦 Docker containers:"
	@docker ps -a --filter name=nginx --filter name=wordpress --filter name=mariadb

	@echo "\n🟩 Docker volumes:"
	@docker volume ls | grep -E 'mariadb_data|wordpress_data' || echo "No volumes found"

	@echo "\n🟨 Docker volume paths:"
	@echo "MariaDB:    /home/serferna/data/mariadb"
	@echo "WordPress:  /home/serferna/data/wordpress"
	@sudo ls -l /home/serferna/data/

	@echo "\n🟪 Docker network:"
	@docker network ls | grep inception || echo "No network found"

secrets:
	@echo "🔐 Generating Docker secrets..."
	@cd secrets && ./generate_secrets.sh

secrets-status:
	@echo "🔐 Docker secrets status:"
	@if [ -d "secrets" ]; then \
		echo "✅ Secrets directory exists"; \
		for file in db_root_password.txt db_user_password.txt wp_admin_password.txt wp_second_password.txt; do \
			if [ -f "secrets/$$file" ]; then \
				echo "✅ $$file exists"; \
			else \
				echo "❌ $$file missing"; \
			fi; \
		done; \
	else \
		echo "❌ Secrets directory missing"; \
	fi

secrets-clean:
	@echo "🧹 Removing generated secrets..."
	@rm -f secrets/db_root_password.txt secrets/db_user_password.txt
	@rm -f secrets/wp_admin_password.txt secrets/wp_second_password.txt
	@echo "✅ Secrets removed"

help:
	@echo "🚀 Inception Makefile Commands:"
	@echo "  make up         - Start all containers"
	@echo "  make down       - Stop all containers"
	@echo "  make re         - Restart all containers"
	@echo "  make logs       - Show container logs"
	@echo "  make clean      - Remove containers and images"
	@echo "  make fclean     - Full cleanup (containers, volumes, data)"
	@echo "  make status     - Show project status"
	@echo "  make volumes    - Show volume information"
	@echo "  make secrets    - Generate Docker secrets"
	@echo "  make secrets-status - Check secrets status"
	@echo "  make secrets-clean  - Remove generated secrets"
