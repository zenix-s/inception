# Inception Project Makefile

# Variables
COMPOSE_FILE = srcs/docker-compose.yml
DATA_PATH = /home/$(USER)/data

# Colors for output
GREEN = \033[0;32m
RED = \033[0;31m
YELLOW = \033[1;33m
NC = \033[0m # No Color

.PHONY: all build up down clean fclean re logs ps help

# Default target
all: build up

# Build all containers
build:
	@echo "$(YELLOW)Building Docker images...$(NC)"
	@mkdir -p $(DATA_PATH)/wordpress
	@mkdir -p $(DATA_PATH)/mariadb
	@docker compose -f $(COMPOSE_FILE) build

# Start all services
up:
	@echo "$(GREEN)Starting services...$(NC)"
	@docker compose -f $(COMPOSE_FILE) up -d

# Stop all services
down:
	@echo "$(RED)Stopping services...$(NC)"
	@docker compose -f $(COMPOSE_FILE) down

# View logs
logs:
	@docker compose -f $(COMPOSE_FILE) logs -f

# Show running containers
ps:
	@docker compose -f $(COMPOSE_FILE) ps

# Clean containers and networks
clean: down
	@echo "$(YELLOW)Cleaning containers and networks...$(NC)"
	@docker system prune -f

# Full clean including volumes and images
fclean: down
	@echo "$(RED)Full cleanup - removing everything...$(NC)"
	@docker compose -f $(COMPOSE_FILE) down -v --rmi all
	@docker system prune -af
	@docker volume prune -f
	@sudo rm -rf $(DATA_PATH)

# Rebuild everything
re: fclean all

# Show help
help:
	@echo "$(GREEN)Available targets:$(NC)"
	@echo "  $(YELLOW)all$(NC)     - Build and start all services"
	@echo "  $(YELLOW)build$(NC)   - Build all Docker images"
	@echo "  $(YELLOW)up$(NC)      - Start all services"
	@echo "  $(YELLOW)down$(NC)    - Stop all services"
	@echo "  $(YELLOW)logs$(NC)    - Show logs from all services"
	@echo "  $(YELLOW)ps$(NC)      - Show running containers"
	@echo "  $(YELLOW)clean$(NC)   - Clean containers and networks"
	@echo "  $(YELLOW)fclean$(NC)  - Full cleanup (removes volumes and data)"
	@echo "  $(YELLOW)re$(NC)      - Rebuild everything from scratch"
	@echo "  $(YELLOW)help$(NC)    - Show this help message"
