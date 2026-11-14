#!/usr/bin/env bash
# Local equivalent of .github/workflows/lint.yml (which uses the linters' own
# actions for annotations): actionlint and zizmor for workflows, hadolint for
# Dockerfiles. Needs Docker and uv.
set -euo pipefail
source "$(dirname "$0")/lib.sh"
cd "$(dirname "$0")/.."

hadolint_all() {
  local file status=0
  while IFS= read -r file; do
    echo "$file"
    docker run --rm -i hadolint/hadolint hadolint --failure-threshold warning - < "$file" || status=1
  done < <(git ls-files '*Dockerfile*')
  return $status
}

step docker run --rm -v "$PWD:/repo:ro" -w /repo rhysd/actionlint -color
step uvx zizmor --min-severity medium .github/workflows
step hadolint_all
