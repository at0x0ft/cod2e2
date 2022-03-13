#!/usr/bin/env sh
set -eu

up_docker_container() {
  local readonly SOURCE_FILE_PATH='src'
  local readonly SOURCE_DOCKER_COMPOSE_FILE="${CONTAINER_WORKSPACE_FOLDER}/${SOURCE_FILE_PATH}/docker-compose.yml"
  local readonly DEVELOPMENT_DOCKER_COMPOSE_FILE="${CONTAINER_WORKSPACE_FOLDER}/docker-compose.dev.yml"
  cd "${CONTAINER_WORKSPACE_FOLDER}"
  docker-compose -f "${SOURCE_DOCKER_COMPOSE_FILE}" -f "${DEVELOPMENT_DOCKER_COMPOSE_FILE}" up -d
}
up_docker_container
