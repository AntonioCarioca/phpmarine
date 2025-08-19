# Makefile for the phpmarine Project
# ==================================
# Use ‘make’ or ‘make help’ to see the available commands.

# Disables printing of executed commands
.SILENT:

# Set all targets to “phony” so that Make doesn't confuse them with file names
.PHONY: help up down restart build status logs shell composer test db-shell db-export db-import clean

# Standard target: displays help
default: help

# --- Variables ---
COMPOSE := docker compose
PHP_SERVICE := php
DB_SERVICE := mysql

# --- Environment Life Cycle Commands ---

up: ## Starts all service containers in the background
	@echo "🚀 Climbing the containers..."
	$(COMPOSE) up -d

down: ## Stop and remove containers, networks and anonymous volumes
	@echo "🛑 Stopping the containers..."
	$(COMPOSE) down --remove-orphans

restart: ## Restart all containers
	@echo "🔄 Restarting containers..."
	$(COMPOSE) restart

build: ## Rebuild Docker images without caching
	@echo "🛠️ Building Docker images from scratch..."
	$(COMPOSE) build --no-cache

clean: ## Stops everything and removes the data volumes (CAUTION: deletes the database)
	@echo "💣 Removing containers and data volumes..."
	$(COMPOSE) down -v --remove-orphans
	@echo "Thorough cleaning."

# --- Diagnostic and debugging commands ---

status: ## Lists containers and their current status
	@echo "📊 Container status:"
	$(COMPOSE) ps

logs: ## Displays the logs of all services in real time
	@echo "📜 Tracking the logs... (Press Ctrl+C to exit)"
	$(COMPOSE) logs -f

# --- Development tool commands ---

shell: ## Accesses the PHP container's terminal (bash)
	@echo "💻 Accessing the PHP container terminal..."
	$(COMPOSE) exec $(PHP_SERVICE) bash

composer: ## Run Composer. Specify the directory with DIR. Ex: make composer ARGS="install" DIR="blog"
	@echo "📦 Running Composer in /app/$(DIR): $(ARGS)"
	WORK_DIR=$(DIR) $(COMPOSE) --profile composer run --rm composer $(ARGS)

test: ## Run PHPUnit. Specify the directory with DIR. Ex: make test DIR="blog"
	@echo "🧪 Running tests in /app/$(DIR): $(ARGS)"
	WORK_DIR=$(DIR) $(COMPOSE) --profile phpunit run --rm phpunit $(ARGS)

# --- Database Management Commands ---

db-shell: ## Accesses the MariaDB/MySQL command line client
	@echo "🗃️ Accessing the MariaDB shell..."
	$(COMPOSE) exec $(DB_SERVICE) mariadb -u"$(MYSQL_USER)" -p"$(MYSQL_PASSWORD)" "$(MYSQL_DATABASE)"

db-export: ## Exports the database to a backup.sql file at the root of the project
	@echo "📤 Exporting database to backup.sql..."
	$(COMPOSE) exec $(DB_SERVICE) sh -c 'mariadb-dump -u"$${MYSQL_USER}" -p"$${MYSQL_PASSWORD}" "$${MYSQL_DATABASE}"' > backup.sql
	@echo "Backup completed in backup.sql"

db-import: ## Import the database from a backup.sql file
	@echo "📥 Importing backup.sql database..."
	$(COMPOSE) exec -T $(DB_SERVICE) sh -c 'mariadb -u"$${MYSQL_USER}" -p"$${MYSQL_PASSWORD}" "$${MYSQL_DATABASE}"' < backup.sql
	@echo "✅ Import completed."


# --- Ajuda ---

help: ## Displays this help message with all available commands
	@echo "PHPMARINE Project Makefile - Available Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""