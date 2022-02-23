#!/usr/bin/env sh
set -eu

check_internal_difference() {
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

  change_directory_to_repository_root() {
    local readonly REPOSITORY_ROOT="${SCRIPT_ROOT}/.."
    cd "${REPOSITORY_ROOT}"
    return 0
  }

  compare_original_to_derived() {
    local readonly COMPARE_LIST_DIRPATH="${SCRIPT_ROOT}/compare_list/internal"
    local readonly SEARCH_FILELIST_PATH="${COMPARE_LIST_DIRPATH}/search_files"
    local readonly ORIGINAL_DERIVED_PAIRLIST_PATH="${COMPARE_LIST_DIRPATH}/original_derived_pairs"

    compare_files() {
      set +e
      # change here with your preferred diff command chain!
      command -v delta 2>&1 >/dev/null
      if [ "${?}" -eq 0 ]; then
        diff -su "${1}" "${2}" | delta --side-by-side
      # default diff part
      else
        diff -s "${1}" "${2}"
      fi
      set -e
      return 0
    }

    for dir_path_pair in $(cat "${ORIGINAL_DERIVED_PAIRLIST_PATH}"); do
      local original_dirpath=${dir_path_pair%%:*}
      local derived_dirpath=${dir_path_pair##*:}
      for file_path in $(cat "${SEARCH_FILELIST_PATH}"); do
        local original_filepath="${original_dirpath}/${file_path}"
        local derived_filepath="${derived_dirpath}/${file_path}"
        if [ -e "${original_filepath}" -a -e "${derived_filepath}" ]; then
          compare_files "${original_filepath}" "${derived_filepath}"
        fi
      done
    done
  }

  change_directory_to_repository_root
  compare_original_to_derived
  return 0
}
check_internal_difference
