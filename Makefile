include .env
export

export PROJECT_ROOT=${shell pwd}

env-up:
	@docker compose up -d todoapp-postgres

env-down:
	@docker compose down todoapp-postgres

env-cleanup:
	@read -p "Clean all the volume files? [y/n]?:" ans; \
	if [ "$$ans" = "y" ]; then \
		docker compose down todoapp-postgres && \
		sudo rm -rf out/pgdata && \
		echo "Deleted"; \
	else \
		echo "Deleting cancelled"; \
	fi

migrate-create:
	@if [ -z "$(seq)" ]; then \
		echo "missing param seq. Ex: make migrate-create seq=1 name=create_users_table"; \
		exit 1; \
	fi; \
	if [ -z "$(name)" ]; then \
		echo "missing param name. Ex: make migrate-create seq=1 name=create_users_table"; \
		exit 1; \
	fi; \
	docker compose run --rm todoapp-postgres-migrate create \
		-ext sql \
		-dir /migrations \
		-seq \
		"$(name)"
		
migrate-up:
	@make migrate-action action=up

migrate-down:
	@make migrate-action action=down

migrate-action:
	@if [ -z "$(action)" ]; then \
		echo "missing param action. Ex: make migrate-action action=up"; \
		exit 1; \
	fi; \
	docker compose run --rm todoapp-postgres-migrate \
		-path /migrations \
		-database postgres://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@todoapp-postgres:5432/$(POSTGRES_DB)?sslmode=disable \
		"$(action)"

env-port-forward:
	@docker compose up -d port-forwarder

env-port-close:
	@docker compose down port-forwarder