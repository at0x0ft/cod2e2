#!/usr/bin/env sh
set -eu

generate_docker_compose() {
  # ref: https://github.com/ko1nksm/readlinkf/blob/master/readlinkf.sh
  readlinkf() {
    [ "${1:-}" ] || return 1
    max_symlinks=40
    CDPATH='' # to avoid changing to an unexpected directory

    target=$1
    [ -e "${target%/}" ] || target=${1%"${1##*[!/]}"} # trim trailing slashes
    [ -d "${target:-/}" ] && target="$target/"

    cd -P . 2>/dev/null || return 1
    while [ "$max_symlinks" -ge 0 ] && max_symlinks=$((max_symlinks - 1)); do
      if [ ! "$target" = "${target%/*}" ]; then
        case $target in
          /*) cd -P "${target%/*}/" 2>/dev/null || break ;;
          *) cd -P "./${target%/*}" 2>/dev/null || break ;;
        esac
        target=${target##*/}
      fi

      if [ ! -L "$target" ]; then
        target="${PWD%/}${target:+/}${target}"
        printf '%s\n' "${target:-/}"
        return 0
      fi

      # `ls -dl` format: "%s %u %s %s %u %s %s -> %s\n",
      #   <file mode>, <number of links>, <owner name>, <group name>,
      #   <size>, <date and time>, <pathname of link>, <contents of link>
      # https://pubs.opengroup.org/onlinepubs/9699919799/utilities/ls.html
      link=$(ls -dl -- "$target" 2>/dev/null) || break
      target=${link#*" $target -> "}
    done
    return 1
  }

  local readonly DEVCONTAINER_ROOT=$(dirname $(readlinkf "${0}"))'/..'
  local readonly REPOSITORY_ROOT="${DEVCONTAINER_ROOT}/.."
  local readonly ENV_FILE="${REPOSITORY_ROOT}/.env"
  local readonly DEVENV_CONFIG_FILE="${DEVCONTAINER_ROOT}/config"

  local line
  for line in $(cat "${ENV_FILE}"); do
    eval "local readonly ${line}"
  done
  for line in $(cat "${DEVENV_CONFIG_FILE}"); do
    eval "local readonly ${line}"
  done

  # development container preparing
  local readonly runtime_base_container_context_absolute_path=$(readlinkf $(dirname "${DEVCONTAINER_ROOT}/${SOURCE_CODE_DOCKER_COMPOSE_PATH}")"/${SOURCE_CODE_DOCKER_CONTEXT}")
  local readonly development_container_context_absolute_path=$(readlinkf $(dirname "${DEVCONTAINER_ROOT}/${DEVELOPMENT_DOCKER_COMPOSE_FILE}")"/${DEVELOPMENT_DOCKER_CONTEXT}")

  calculate_relative_path() {
    local readonly origin=$(readlinkf "${1}")
    local readonly destination=$(readlinkf "${2}")

    get_common_parent_path() {
      local path1="${1#/}"
      local path2="${2#/}"
      local result=''
      while true; do
        local dirname1="${path1%%/*}"
        path1="${path1#*/}"
        local dirname2="${path2%%/*}"
        path2="${path2#*/}"
        if [ "${dirname1}" != "${dirname2}" ]; then
          printf "%s" "${result}"
          return 0
        fi
        result="${result}/${dirname1}"
      done
      return 1
    }
    local readonly common_parent_path=$(get_common_parent_path "${origin}" "${destination}")

    get_relative_path_from_common() {
      local readonly path="${1}"
      local readonly common_path="${2}"
      local readonly rest_path=${path##"${common_path}"}
      printf '%s' "${rest_path#?}"
      return 0
    }
    local readonly common_to_origin_relative_path=$(get_relative_path_from_common "${origin}" "${common_parent_path}")
    local readonly common_to_destination_relative_path=$(get_relative_path_from_common "${destination}" "${common_parent_path}")

    calculate_relative_ancestor_path() {
      local path="${1}"
      local result=''
      if [ "${path}" = "" ]; then
        printf '%s' "${result}"
        return 0
      fi

      result='..'
      while [ "${path}" != "${path%/*}" ]; do
        result="${result}/.."
        path="${path%/*}"
      done
      printf '%s' "${result}"
      return 0
    }
    local readonly relative_ancestor_path=$(calculate_relative_ancestor_path "${common_to_origin_relative_path}")

    connect_origin_to_destination_relative_path() {
      local readonly relative_ancestor_path="${1}"
      local readonly relative_descendant_path="${2}"
      if [ "${relative_ancestor_path}" = "" ]; then
        printf '%s' "${relative_descendant_path}"
        return 0
      fi
      printf '%s/%s' "${relative_ancestor_path}" "${relative_descendant_path}"
      return 0
    }
    printf '%s' $(connect_origin_to_destination_relative_path "${relative_ancestor_path}" "${common_to_destination_relative_path}")
    return 0
  }
  local readonly development_container_context_path=$(calculate_relative_path "${runtime_base_container_context_absolute_path}" "${development_container_context_absolute_path}")

  local readonly development_docker_compose_template_path=$(readlinkf "${DEVCONTAINER_ROOT}/${DEVELOPMENT_DOCKER_COMPOSE_TEMPLATE_FILE}")
  local readonly development_docker_compose_path=$(readlinkf "${DEVCONTAINER_ROOT}/${DEVELOPMENT_DOCKER_COMPOSE_FILE}")

  # runtime container preparing
  local readonly runtime_container_context_absolute_path=$(readlinkf $(dirname "${DEVCONTAINER_ROOT}/${DEVELOPMENT_DOCKER_COMPOSE_FILE}")"/${RUNTIME_DOCKER_CONTEXT}")
  local readonly runtime_container_context_path=$(calculate_relative_path "${runtime_base_container_context_absolute_path}" "${runtime_container_context_absolute_path}")

  get_runtime_base_image_name() {
    local readonly source_code_docker_compose_absolute_path="${DEVCONTAINER_ROOT}/${SOURCE_CODE_DOCKER_COMPOSE_PATH}"
    docker-compose -f "${source_code_docker_compose_absolute_path}" --env-file "${ENV_FILE}" build "${SOURCE_CODE_RUNTIME_BASE_SERVICE_NAME}" >/dev/null 2>&1
    printf '%s_%s' "${COMPOSE_PROJECT_NAME}" "${SOURCE_CODE_RUNTIME_BASE_SERVICE_NAME}"
    return 0
  }
  local readonly runtime_base_image_name=$(get_runtime_base_image_name)

  local readonly local_container_working_directory=$(readlinkf "${REPOSITORY_ROOT}")

  get_vscode_extension_volume_name() {
    printf '%s-extensions' "${COMPOSE_PROJECT_NAME}"
    return 0
  }

  get_vscode_insider_extension_volume_name() {
    printf '%s-insider-extensions' "${COMPOSE_PROJECT_NAME}"
    return 0
  }
  local readonly vscode_extension_volume_name=$(get_vscode_extension_volume_name)
  local readonly vscode_insider_extension_volume_name=$(get_vscode_insider_extension_volume_name)
  local readonly vscode_extension_path="/home/${DEVELOPMENT_CONTAINER_USERNAME}/.vscode-server/extensions"
  local readonly vscode_insider_extension_path="/home/${DEVELOPMENT_CONTAINER_USERNAME}/.vscode-server-insiders/extensions"

  local readonly prev_IFS="${IFS}"
  IFS='\n'
  while read line; do
    eval "printf '%s\n' \"${line}\""
  done <"${development_docker_compose_template_path}" > "${development_docker_compose_path}"
  IFS="${prev_IFS}"
  return 0
}
generate_docker_compose
