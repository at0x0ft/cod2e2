#!/usr/bin/env sh
set -e

readonly SCRIPT_PATH=$(
  self=${0}
  while [ -L "${self}" ]; do
    cd "${self%/*}"
    self=$(readlink "${self}")
  done
  cd "${self%/*}"
  echo "$(pwd -P)/${self##*/}"
)
readonly SCRIPT_ROOT="$(dirname ${SCRIPT_PATH})"
cd "${SCRIPT_ROOT}"

usage() {
  printf '-h, --help : help\n'
  printf '-, -- : \n'
}

# "${1}" = clone souce template path (relative path from this script)
# "${2}" = clone destination path
# TODO: valitating and resolving these argument paths are absolute or relative

# TODO: Option selection from the existed templates
# TODO: clone only whitelist templates

cp -rv "${1}" "${2}"

# TODO: register clone destination path
