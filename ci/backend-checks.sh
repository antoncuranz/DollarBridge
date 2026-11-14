#!/usr/bin/env bash
# Backend checks: run by .github/workflows/backend-checks.yml and `make ci`.
# Needs uv; pytest needs Docker (testcontainers binds host port 5434).
set -euo pipefail
source "$(dirname "$0")/lib.sh"
cd "$(dirname "$0")/../backend"

step uv sync --locked
step uv run --locked ruff format --check .
step uv run --locked ruff check .
step uv run --locked mypy .
step uv run --locked pytest -q
