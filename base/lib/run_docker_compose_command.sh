#!/usr/bin/env sh
set -eu

run_docker_compose_command() {
  # arguments
  local readonly DOCKER_COMPOSE_FILEPATH="${1}"
  shift
  local readonly DOCKER_COMPOSE_RUNTIME_CONTAINER_SERVICE_NAME="${1}"
  shift
  local readonly RUNTIME_CONTAINER_WORKING_DIRPATH="${1}"
  shift
  local readonly RUNTIME_CONTAINER_EXECUTE_COMMAND="${1}"
  shift

  convert_devcontainer_filepath_to_runtime_container_filepath() {
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

    local readonly file_absolute_path=$(readlinkf "${1}")
    local readonly docker_host_filepath="${LOCAL_WORKSPACE_FOLDER}${file_absolute_path#$CONTAINER_WORKSPACE_FOLDER}"
    printf '%s%s\n' "${RUNTIME_CONTAINER_WORKING_DIRPATH}" "${docker_host_filepath#$LOCAL_WORKSPACE_FOLDER}"
    return 0
  }

  convert_path_in_arguments() {
    convert_filepath_if_exists() {
      if [ -e "${1}" ]; then
        printf '%s\n' $(convert_devcontainer_filepath_to_runtime_container_filepath "${1}")
      else
        printf '%s\n' "${1}"
      fi
      return 0
    }

    local result=''
    local argument_index=1
    for argument in "${@}"; do
      result="${result}"$(convert_filepath_if_exists ${argument})
      if [ "${argument_index}" -lt "${#}" ]; then
        result="${result} "
      fi
      argument_index=$((argument_index+1))
    done
    printf '%s\n' "${result}"
    return 0
  }

  local readonly container_mountpoint="${LOCAL_WORKSPACE_FOLDER}:${RUNTIME_CONTAINER_WORKING_DIRPATH}"
  local readonly runtime_container_current_working_dirpath=$(convert_devcontainer_filepath_to_runtime_container_filepath $(pwd))
  local readonly converted_execute_arguments=$(convert_path_in_arguments "${@}")
  docker-compose -f "${DOCKER_COMPOSE_FILEPATH}" \
    run -v '/etc/group:/etc/group:ro' -v '/etc/passwd:/etc/passwd:ro' \
    -u $(id -u ${USER}):$(id -g ${USER}) \
    -v "${container_mountpoint}" \
    -w "${RUNTIME_CONTAINER_WORKING_DIRPATH}" \
    "${DOCKER_COMPOSE_RUNTIME_CONTAINER_SERVICE_NAME}" \
    sh -c "cd ${runtime_container_current_working_dirpath} && ${RUNTIME_CONTAINER_EXECUTE_COMMAND} ${converted_execute_arguments}"
}
