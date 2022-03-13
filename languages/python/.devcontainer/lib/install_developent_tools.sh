#!/usr/bin/env sh
set -eu

install_development_tools() {
  local readonly FORMATTER='black'
  local readonly LINTER='pyproject-flake8'
  local readonly LINTER_PLUGIN='flake8-bugbear'
  local readonly TYPE_CHECKER='pyright'
  local readonly IMPORT_SORT='isort'

  poetry add --dev "${FORMATTER}" "${LINTER}" "${LINTER_PLUGIN}" "${TYPE_CHECKER}" "${IMPORT_SORT}"
}
install_development_tools
