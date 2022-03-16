#!/usr/bin/env sh
set -eu

reset_extension_volumes() {
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

  local readonly DEVCONTAINER_ROOT=$(dirname $(readlinkf "${0}"))
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

  get_docker_container_name() {
    readonly local compose_service_name="${1}"
    printf '%s_%s_1' "${COMPOSE_PROJECT_NAME}" "${compose_service_name}"
    return 0
  }

  local readonly development_base_container_name=$(get_docker_container_name ${DEVELOPMENT_BASE_CONTAINER_SERVICE_NAME})

  docker_container_exists() {
    local readonly container_name="${1}"
    local readonly container_id=$(docker container ls --all --filter "name=${container_name}" --quiet)
    if [ "${container_id}" != '' ]; then
      return 0
    else
      return 1
    fi
  }

  if docker_container_exists "${development_base_container_name}"; then
    docker container rm -f "${development_base_container_name}"
  fi

  get_docker_volume_name() {
    readonly local compose_volume_name="${1}"
    printf '%s_%s' "${COMPOSE_PROJECT_NAME}" "${compose_volume_name}"
    return 0
  }

  local readonly vscode_extension_volume_name=$(get_docker_volume_name "${VSCODE_EXTENSION_VOLUME_NAME}")
  local readonly vscode_insider_extension_volume_name=$(get_docker_volume_name "${VSCODE_INSIDER_EXTENSION_VOLUME_NAME}")

  docker_volume_exists() {
    local readonly volume_name="${1}"
    local readonly volume_result=$(docker volume ls --filter "name=${volume_name}" --quiet)
    if [ "${volume_result}" != '' ]; then
      return 0
    else
      return 1
    fi
  }

  if docker_volume_exists "${vscode_extension_volume_name}"; then
    docker volume rm "${vscode_extension_volume_name}"
  fi
  if docker_volume_exists "${vscode_insider_extension_volume_name}"; then
    docker volume rm "${vscode_insider_extension_volume_name}"
  fi
  return 0
}
reset_extension_volumes
