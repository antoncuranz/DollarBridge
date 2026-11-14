#!/usr/bin/env bash
# Frontend checks: run by .github/workflows/frontend-checks.yml and `make ci`.
# Needs Node and the npm version from package.json → packageManager.
set -euo pipefail
source "$(dirname "$0")/lib.sh"
cd "$(dirname "$0")/../frontend"

step npm ci --no-audit --no-fund
step npm run format:check
step npm run lint
step npm test
step npm run build
