.PHONY: dev down build-go build-node run-go run-node prepare-env execute-migrations execute-seeds prisma-generate

GO_DIR=packages/payments-processor
NODE_DIR=packages/payments-microservice

dev: prepare-env execute-migrations build-node build-go run-node run-go
	@echo "🚀 Development started: apps are running!"
	@wait

prepare-env:
	@echo "📋 Copying .env.example to .env if missing..."
	@if [ -f $(GO_DIR)/.env.example ] && [ ! -f $(GO_DIR)/.env ]; then cp $(GO_DIR)/.env.example $(GO_DIR)/.env; fi
	@if [ -f $(NODE_DIR)/.env.example ] && [ ! -f $(NODE_DIR)/.env ]; then cp $(NODE_DIR)/.env.example $(NODE_DIR)/.env; fi

execute-migrations:
	@echo "🛠️ Running database migrations..."
	@cd $(NODE_DIR) && npm run migrate

build-node: execute-seeds
	@echo "📦 Installing Node.js packages..."
	@cd $(NODE_DIR) && npm install --silent && npm run build
	@$(MAKE) prisma-generate

prisma-generate:
	@echo "⚙️ Running Prisma generate..."
	@cd $(NODE_DIR) && npx --yes prisma generate

execute-seeds:
	@echo "🌱 Running database seeds..."
	@cd $(NODE_DIR) && npm run seed

build-go:
	@echo "🏗️ Building Go application..."
	@cd $(GO_DIR) && make build

run-node:
	@echo "▶️ Starting Node.js app..."
	@cd $(NODE_DIR) && npm run start &

run-go:
	@echo "▶️ Starting Go app..."
	@cd $(GO_DIR) && make run &

down:
	@echo "🛑 Stopping Node.js and Go servers..."
	@pkill -f "npm run start" || echo "Node.js not running"
	@pkill -f "$(GO_DIR)/app" || echo "Go app not running"
