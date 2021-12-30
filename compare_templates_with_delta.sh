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
readonly COMPARE_SCRIPT_NAME='compare_templates.sh'
readonly DIFF_COMMAND_WITH_DELTA='diff -u "${1}" "${2}" | delta --side-by-side'

DIFF_COMMAND="${DIFF_COMMAND_WITH_DELTA}" "${SCRIPT_ROOT}/${COMPARE_SCRIPT_NAME}" "${1}" "${2}"
