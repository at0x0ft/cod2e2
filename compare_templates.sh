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
# TODO: format argument paths

readonly DIFF="${DIFF_COMMAND:-diff}"
readonly VALID_DIRNAME='.devcontainer'

enumerate_template_files() {
  # TODO: split checking valid filename white/black list
  find "${1}/${VALID_DIRNAME}" -maxdepth 1 -follow -type f
}

# TODO: Option selection from the existed templates
# TODO: Option selection from the registered cloned templates
for template_file in $(enumerate_template_files "${1}"); do
  # echo "path = ${template_file}" # 4debug
  filename=$(basename "${template_file}")
  "${DIFF}" "${1}/${VALID_DIRNAME}/${filename}" "${2}/${VALID_DIRNAME}/${filename}"
done
