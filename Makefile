# Local development. `make dev` starts the database (seeded from seed.sql),
# the backend and the frontend; Ctrl-C stops backend and frontend.
# `make ci` runs the same checks as the CI workflows (scripts in ci/).

DEV_USER      ?= alice
DB_PORT       ?= 5433
BACKEND_PORT  ?= 8000
FRONTEND_PORT ?= 3000

.PHONY: init-worktree dev dev-frontend db db-reset db-load db-stop backend frontend ci ci-backend ci-frontend ci-lint

## dependencies of a fresh checkout or worktree (used by orca.yaml)
init-worktree:
	cd backend && uv sync --locked
	cd frontend && npm ci --prefer-offline --no-audit --no-fund

dev: db frontend/node_modules
	@$(MAKE) --no-print-directory -j2 backend dev-frontend

# Vite starts once the backend answers, and without terminal input: its keyboard
# shortcuts would swallow the terminal's reply to the color query `fastapi dev`
# sends on startup, which leaves the backend hanging.
dev-frontend:
	@until curl -sf -o /dev/null http://127.0.0.1:$(BACKEND_PORT)/docs; do sleep 1; done
	@$(MAKE) --no-print-directory frontend < /dev/null

PSQL = PGPASSWORD=postgres psql -h localhost -p $(DB_PORT) -U postgres -d postgres

## database: Postgres on :$(DB_PORT); loads seed.sql only into an empty database
db:
	@if ! pg_isready -q -h localhost -p $(DB_PORT); then \
		echo "starting postgres on :$(DB_PORT)..."; \
		docker run --rm -d --name money-tracking-db-$(DB_PORT) -e POSTGRES_PASSWORD=postgres \
			-p $(DB_PORT):5432 postgres:17-alpine >/dev/null; \
	fi
	@until $(PSQL) -qc 'select 1' >/dev/null 2>&1; do sleep 1; done
	@if [ "$$($(PSQL) -Atc "select to_regclass('public.alembic_version') is not null")" = t ]; then \
		echo "database on :$(DB_PORT) already has data; 'make db-reset' reloads seed.sql"; \
	else \
		$(MAKE) --no-print-directory db-load; \
	fi

## database: drop everything and reload seed.sql
db-reset: db
	@$(MAKE) --no-print-directory db-load

db-load:
	@echo "loading seed.sql (users: alice, bob)..."
	@$(PSQL) -q -v ON_ERROR_STOP=1 -f seed.sql >/dev/null

db-stop:
	@docker stop money-tracking-db-$(DB_PORT) >/dev/null 2>&1 && echo "stopped" || echo "not running"

backend:
	cd backend && POSTGRES_PORT=$(DB_PORT) POSTGRES_DATABASE=postgres OVERWRITE_USER_HEADER=$(DEV_USER) \
		uv run --locked fastapi dev main.py --port $(BACKEND_PORT)

frontend: frontend/node_modules
	cd frontend && BACKEND_URL=http://127.0.0.1:$(BACKEND_PORT) npx vite --port $(FRONTEND_PORT)

frontend/node_modules: frontend/package-lock.json
	cd frontend && npm ci --no-audit --no-fund
	@touch $@

## checks: everything CI runs (backend, frontend, workflow and Dockerfile lint)
ci: ci-backend ci-frontend ci-lint

ci-backend:
	@ci/backend-checks.sh

ci-frontend:
	@ci/frontend-checks.sh

ci-lint:
	@ci/repo-lint.sh
