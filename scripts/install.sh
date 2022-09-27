#!/usr/bin/env bash
#
# Date:   2022-09-22
# Author: Erik Ccanto

set -euo pipefail

readonly INSTALLATION_DIRECTORY="/usr/bin/"
readonly SCRIPT_DIRECTORY="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

. "${SCRIPT_DIRECTORY}/common.sh"

bash "${SCRIPT_DIRECTORY}/build.sh"

echo -e "${GREEN_COLOR}\ninstalling application...\n${END_COLOR}"

cp "${BUILD_DIRECTORY}/${APPLICATION_NAME}" "${INSTALLATION_DIRECTORY}"

echo -e "${GREEN_COLOR}the application has been installed successfully:${END_COLOR} $(which ${APPLICATION_NAME})"
