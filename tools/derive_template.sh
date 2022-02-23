#!/usr/bin/env sh
set -eu

derive_template() {
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
  local readonly SCRIPT_PATH=$(readlinkf "${0}")
  local readonly SCRIPT_ROOT=$(dirname "${SCRIPT_PATH}")
  local readonly REPOSITORY_ROOT=$(readlinkf "${SCRIPT_ROOT}/..")

  local template_path
  select_template() {
    local readonly TEMPLATES_ROOT="${REPOSITORY_ROOT}/languages"
    show_available_templates() {
      printf '\n========== Available templates ==========\n'
      ls -1 "${TEMPLATES_ROOT}"
      printf '=========================================\n\n'
    }

    local template_name
    while true; do
      show_available_templates
      printf 'Enter template name you want to derive: '
      read template_name
      template_path="${TEMPLATES_ROOT}/${template_name}"
      if [ -e "${template_path}" ]; then
        return 0
      else
        printf 'Not available "%s"!\n' "${template_name}"
      fi
    done
    return 1
  }

  local destination_path
  input_destination_path() {
    printf 'Enter destination path: '
    read destination_path
    return 0
  }

  register_destination_path() {
    local readonly COMPARE_LIST_DIRPATH="${SCRIPT_ROOT}/compare_list/external"

    local readonly template_name=$(basename "${1}")
    local readonly compare_list_root="${COMPARE_LIST_DIRPATH}/${template_name}"
    local readonly compare_derived_list_path="${compare_list_root}/derived"
    concat_pathlist() {
      if [ -e "${compare_derived_list_path}" ]; then
        local readonly derived_list_content=$(cat "${compare_derived_list_path}")
        if [ ! -z "${derived_list_content}" ]; then
          printf '%s\n%s\n' "${derived_list_content}" "${1}"
          return 0
        fi
      fi
      printf '%s\n' "${1}"
      return 0
    }

    local readonly new_pathlist_content=$(concat_pathlist $(readlinkf "${2}"))
    printf '%s\n' "${new_pathlist_content}" | sort | uniq > "${compare_derived_list_path}"
    return 0
  }

  select_template
  input_destination_path
  cp -rv "${template_path}" "${destination_path}"
  register_destination_path "${template_path}" "${destination_path}"
  return 0
}
derive_template
