all: up

up:
	@mkdir -p /home/${USER}/data/mysql
	@mkdir -p /home/${USER}/data/wordpress
	@docker-compose -f srcs/docker-compose.yml up -d --build

down:
	@docker-compose -f srcs/docker-compose.yml down

clean:
	@docker-compose -f srcs/docker-compose.yml down -v
	@docker system prune -af

fclean: clean
	@sudo rm -rf /home/${USER}/data

re: fclean all

.PHONY: all up down clean fclean re
