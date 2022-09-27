#!/usr/bin/env bash
#
# Date:   2022-09-22
# Author: Erik Ccanto

set -euo pipefail

readonly SCRIPT_DIRECTORY="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
readonly EXCLUDE_FILES=(
    "captures"
    "scripts"
    "build"
    "bin"
    "documentation"
    "setup.cfg"
    ".git"
    ".gitignore"
    ".venv"
    ".mypy_cache"
    ".prospector.yml"
    ".shellcheckrc"
)

exclude_arguments=()
for path in "${EXCLUDE_FILES[@]}"; do
    exclude_arguments+=("--exclude=${path}")
done

# shellcheck disable=SC1090
. "${SCRIPT_DIRECTORY}/common.sh"

if ! command -v makeself &> /dev/null; then
    sudo apt install -y makeself
fi

rm -rf "${BUILD_DIRECTORY}"
mkdir -p "${BUILD_DIRECTORY}"

echo -e "${GREEN_COLOR}generating applitaion...\n${END_COLOR}"

makeself --tar-extra "${exclude_arguments[*]}" . "${BUILD_DIRECTORY}/${APPLICATION_NAME}" "Screen capture" ./main.sh

echo -e "${GREEN_COLOR}\nthe application has been generated successfully:${END_COLOR} ${BUILD_DIRECTORY}/${APPLICATION_NAME}"
