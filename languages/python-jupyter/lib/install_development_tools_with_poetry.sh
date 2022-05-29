#!/usr/bin/env sh
set -eu

install_development_tools_with_poetry() {
  local readonly FORMATTER='black'
  local readonly LINTER='pyproject-flake8'
  local readonly LINTER_PLUGIN='flake8-bugbear'
  local readonly IMPORT_SORT='isort'

  poetry add --dev "${FORMATTER}" "${LINTER}" "${LINTER_PLUGIN}" "${IMPORT_SORT}"
  return 0
}
install_development_tools_with_poetry
