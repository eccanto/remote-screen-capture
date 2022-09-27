#!/usr/bin/env bash
#
# Date:   2022-09-22
# Author: Erik Ccanto

# shellcheck disable=SC2034

set -euo pipefail

readonly COMMON_SCRIPT_DIRECTORY="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

readonly BUILD_DIRECTORY="${COMMON_SCRIPT_DIRECTORY}/../build"
readonly APPLICATION_NAME="screen_capture"

readonly BLUE_COLOR="\033[1;34m"
readonly GREEN_COLOR="\033[1;32m"
readonly RED_COLOR="\033[1;31m"
readonly END_COLOR="\033[0m"
