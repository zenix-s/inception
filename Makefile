COMPOSE_FILE = docker-compose.yml

.PHONY: all build up down clean fclean re

all: build up

build:
	docker-compose -f $(COMPOSE_FILE) build

up:
	docker-compose -f $(COMPOSE_FILE) up -d

down:
	docker-compose -f $(COMPOSE_FILE) down

clean:
	docker-compose -f $(COMPOSE_FILE) down -v
	docker system prune -af

fclean: clean
	docker volume rm $$(docker volume ls -q) 2>/dev/null || true
	docker network rm $$(docker network ls -q) 2>/dev/null || true

re: fclean all

logs:
	docker-compose -f $(COMPOSE_FILE) logs -f

status:
	docker-compose -f $(COMPOSE_FILE) ps