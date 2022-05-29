#!/usr/bin/env sh
set -eu

create_new_project_with_poetry() {
  local readonly PROJECT_NAME="${1}"
  local readonly DEFAULT_SOURCE_CODE_DIRNAME='src'
  poetry new --src "${PROJECT_NAME}"
  mv "${PROJECT_NAME}" ${DEFAULT_SOURCE_CODE_DIRNAME}
  return 0
}
create_new_project_with_poetry "${1}"
