#!/usr/bin/env bash
#
# Date:   2022-09-22
# Author: Erik Ccanto

set -euo pipefail

PROJECT_DIR=.

GREEN="32"
BOLDGREEN="\e[1;${GREEN}m"
ENDCOLOR="\e[0m"

# Python static code checkers
echo -e "${BOLDGREEN}> running black...${ENDCOLOR}"
black --check --diff --skip-string-normalization "${PROJECT_DIR}"

echo -e "${BOLDGREEN}> running isort...${ENDCOLOR}"
isort --check-only --diff "${PROJECT_DIR}"

echo -e "${BOLDGREEN}> running prospector...${ENDCOLOR}"
prospector "${PROJECT_DIR}"

# Shell static code checkers
echo -e "${BOLDGREEN}> running shellcheck...${ENDCOLOR}"
find "${PROJECT_DIR}" -name "*.sh" -type f -not -path '*/\.venv/*' -exec shellcheck {} \;
