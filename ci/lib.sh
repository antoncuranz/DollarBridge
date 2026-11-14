# Shared helpers for the ci/ scripts (sourced, not executed).

# step <command...>: runs one check, as a collapsible group on GitHub Actions
step() {
  if [[ -n ${GITHUB_ACTIONS:-} ]]; then
    echo "::group::$*"
  else
    printf '\n\033[1m==> %s\033[0m\n' "$*"
  fi
  "$@"
  local status=$?
  [[ -n ${GITHUB_ACTIONS:-} ]] && echo "::endgroup::"
  return $status
}
