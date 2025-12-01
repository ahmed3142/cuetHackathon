.PHONY: help up down build logs restart shell ps clean clean-all clean-volumes dev-up dev-down dev-build dev-logs dev-restart dev-shell dev-ps prod-up prod-down prod-build prod-logs prod-restart backend-shell gateway-shell mongo-shell backend-build backend-install backend-type-check backend-dev db-reset db-backup status health

# Default mode is development
MODE ?= dev
SERVICE ?= backend
ARGS ?=

# Docker compose file selection
ifeq ($(MODE),prod)
    COMPOSE_FILE = -f docker/compose.production.yaml
else
    COMPOSE_FILE = -f docker/compose.development.yaml
endif

# Help command
help:
@echo "Docker Services:"
@echo "  up           - Start services (use: make up [service...] or make up MODE=prod, ARGS=\"--build\" for options)"
@echo "  down         - Stop services (use: make down [service...] or make down MODE=prod, ARGS=\"--volumes\" for options)"
@echo "  build        - Build containers (use: make build [service...] or make build MODE=prod)"
@echo "  logs         - View logs (use: make logs SERVICE=backend, MODE=prod for production)"
@echo "  restart      - Restart services (use: make restart [service...] or make restart MODE=prod)"
@echo "  shell        - Open shell in container (use: make shell SERVICE=gateway, MODE=prod, default: backend)"
@echo "  ps           - Show running containers (use MODE=prod for production)"
@echo ""
@echo "Convenience Aliases (Development):"
@echo "  dev-up       - Start development environment"
@echo "  dev-down     - Stop development environment"
@echo "  dev-build    - Build development containers"
@echo "  dev-logs     - View development logs"
@echo "  dev-restart  - Restart development services"
@echo "  dev-shell    - Open shell in backend container"
@echo "  dev-ps       - Show running development containers"
@echo "  backend-shell - Open shell in backend container"
@echo "  gateway-shell - Open shell in gateway container"
@echo "  mongo-shell  - Open MongoDB shell"
@echo ""
@echo "Convenience Aliases (Production):"
@echo "  prod-up      - Start production environment"
@echo "  prod-down    - Stop production environment"
@echo "  prod-build   - Build production containers"
@echo "  prod-logs    - View production logs"
@echo "  prod-restart - Restart production services"
@echo ""
@echo "Backend:"
@echo "  backend-build      - Build backend TypeScript"
@echo "  backend-install    - Install backend dependencies"
@echo "  backend-type-check - Type check backend code"
@echo "  backend-dev        - Run backend in development mode (local, not Docker)"
@echo ""
@echo "Database:"
@echo "  db-reset     - Reset MongoDB database (WARNING: deletes all data)"
@echo "  db-backup    - Backup MongoDB database"
@echo ""
@echo "Cleanup:"
@echo "  clean        - Remove containers and networks (both dev and prod)"
@echo "  clean-all    - Remove containers, networks, volumes, and images"
@echo "  clean-volumes - Remove all volumes"
@echo ""
@echo "Utilities:"
@echo "  status       - Alias for ps"
@echo "  health       - Check service health"

# Docker Services
up:
docker compose $(COMPOSE_FILE) up -d $(ARGS) $(filter-out $@,$(MAKECMDGOALS))

down:
docker compose $(COMPOSE_FILE) down $(ARGS) $(filter-out $@,$(MAKECMDGOALS))

build:
docker compose $(COMPOSE_FILE) build $(ARGS) $(filter-out $@,$(MAKECMDGOALS))

logs:
docker compose $(COMPOSE_FILE) logs -f $(SERVICE)

restart:
docker compose $(COMPOSE_FILE) restart $(filter-out $@,$(MAKECMDGOALS))

shell:
docker compose $(COMPOSE_FILE) exec $(SERVICE) /bin/sh

ps:
docker compose $(COMPOSE_FILE) ps

# Development Aliases
dev-up:
@make up MODE=dev

dev-down:
@make down MODE=dev

dev-build:
@make build MODE=dev

dev-logs:
@make logs MODE=dev

dev-restart:
@make restart MODE=dev

dev-shell:
@make shell MODE=dev SERVICE=backend

dev-ps:
@make ps MODE=dev

backend-shell:
@make shell SERVICE=backend

gateway-shell:
@make shell SERVICE=gateway

mongo-shell:
docker compose $(COMPOSE_FILE) exec mongo mongosh -u $$MONGO_INITDB_ROOT_USERNAME -p $$MONGO_INITDB_ROOT_PASSWORD

# Production Aliases
prod-up:
@make up MODE=prod ARGS="--build"

prod-down:
@make down MODE=prod

prod-build:
@make build MODE=prod

prod-logs:
@make logs MODE=prod

prod-restart:
@make restart MODE=prod

# Backend Commands
backend-build:
cd backend && npm run build

backend-install:
cd backend && npm install

backend-type-check:
cd backend && npm run type-check

backend-dev:
cd backend && npm run dev

# Database Commands
db-reset:
@echo "WARNING: This will delete all data in the database!"
@read -p "Are you sure? (yes/no): " confirm; \
if [ "$$confirm" = "yes" ]; then \
docker compose $(COMPOSE_FILE) exec mongo mongosh -u $$MONGO_INITDB_ROOT_USERNAME -p $$MONGO_INITDB_ROOT_PASSWORD --eval "use $$MONGO_DATABASE; db.dropDatabase()"; \
echo "Database reset complete."; \
else \
echo "Database reset cancelled."; \
fi

db-backup:
@mkdir -p backups
docker compose $(COMPOSE_FILE) exec -T mongo mongodump --username $$MONGO_INITDB_ROOT_USERNAME --password $$MONGO_INITDB_ROOT_PASSWORD --db $$MONGO_DATABASE --archive > backups/backup-$(shell date +%Y%m%d-%H%M%S).archive
@echo "Backup created in backups/ directory"

# Cleanup Commands
clean:
docker compose -f docker/compose.development.yaml down
docker compose -f docker/compose.production.yaml down

clean-all:
docker compose -f docker/compose.development.yaml down -v --rmi all
docker compose -f docker/compose.production.yaml down -v --rmi all

clean-volumes:
docker volume rm ecommerce-mongo-data-dev ecommerce-mongo-config-dev ecommerce-mongo-data-prod ecommerce-mongo-config-prod 2>/dev/null || true

# Utility Commands
status: ps

health:
@echo "Checking service health..."
@curl -f http://localhost:5921/health && echo "\nGateway: OK" || echo "\nGateway: FAIL"
@curl -f http://localhost:5921/api/health && echo "Backend: OK" || echo "Backend: FAIL"

# Allow passing service names as arguments
%:
@: