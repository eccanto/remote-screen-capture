#!/usr/bin/env bash
#
# Date:   2022-09-22
# Author: Erik Ccanto

set -euo pipefail

readonly BLUE_COLOR="\033[1;34m"
readonly GREEN_COLOR="\033[1;32m"
readonly RED_COLOR="\033[1;31m"
readonly END_COLOR="\033[0m"

DEVICE_HOSTNAME=
DEVICE_PORT=22
DEVICE_USER=root
WAIT_PROCESS=

DEVICE_DISPLAY=:0
DEVICE_DESTINATION=.screen_capture

CAPTURE_MODE=v

RUN_DIR=${USER_PWD:-$(pwd)}
OUTPUT_DIR="${RUN_DIR}/captures/"

CAPTURE_APPLICATION_ARGUMENTS="-m 0"

function print_usage() {
    echo "Usage: $0 [ -h DEVICE_HOSTNAME ] [ -p DEVICE_PORT ] [ -u DEVICE_USER ] [ -d DEVICE_DISPLAY ] [ -m CAPTURE_MODE ] [ -w WAIT_PROCESS ]"
    echo "  DEVICE_HOSTNAME: ssh hostname     [required]"
    echo "  DEVICE_PORT:     ssh port         (default: 22)"
    echo "  DEVICE_USER:     ssh username     (default: root)"
    echo "  DEVICE_DISPLAY:  device DISPLAY   (default: :0)"
    echo "  CAPTURE_MODE:    capture mode     (default: v (v: video, s: screenshot))"
    echo "  WAIT_PROCESS:    Wait for process [required]"
}

function parse_arguments() {
    while getopts "h:p:u:m:w:d:" flag; do
        case $flag in
            h) DEVICE_HOSTNAME=$OPTARG;;
            p) DEVICE_PORT=$OPTARG;;
            u) DEVICE_USER=$OPTARG;;
            m) CAPTURE_MODE=$OPTARG;;
            w) WAIT_PROCESS=$OPTARG;;
            d) DEVICE_DISPLAY=$OPTARG;;
            *) print_usage; exit 1;;
        esac
    done
}

function run_command_on_device() {
    declare -r command=$1

    ssh -t -p "${DEVICE_PORT}" "${DEVICE_USER}"@"${DEVICE_HOSTNAME}" "${command}"
}

parse_arguments "$@"

if [[ -z "${DEVICE_HOSTNAME}" ]]; then
    print_usage
    echo -e "${RED_COLOR}\nDEVICE_HOSTNAME (-h) is required${END_COLOR}"
    exit 1
fi

if [[ -n "${WAIT_PROCESS}" ]]; then
    CAPTURE_APPLICATION_ARGUMENTS="${CAPTURE_APPLICATION_ARGUMENTS} -p ${WAIT_PROCESS}"
fi

DEVICE_DESTINATION="$(eval echo ~"${DEVICE_USER}")/${DEVICE_DESTINATION}"

# install OS dependencies

if ! command -v ffmpeg &> /dev/null; then
    sudo apt install -y ffmpeg
fi

if ! command -v convert &> /dev/null; then
    sudo apt install -y imagemagick
fi

# main

mkdir -p "${OUTPUT_DIR}"

echo -e "${GREEN_COLOR}connecting to '${DEVICE_USER}@${DEVICE_HOSTNAME}:${DEVICE_PORT}'...${END_COLOR}"

if ! run_command_on_device "ls ${DEVICE_DESTINATION}"; then
    echo -e "${GREEN_COLOR}creating application directory: ${DEVICE_DESTINATION}...${END_COLOR}"
    run_command_on_device "mkdir -p ${DEVICE_DESTINATION}"

    echo -e "${GREEN_COLOR}copying application source to device...${END_COLOR}"
    scp -r -P "${DEVICE_PORT}" {capture.py,requirements.txt,src} "${DEVICE_USER}"@"${DEVICE_HOSTNAME}":"${DEVICE_DESTINATION}"

    echo -e "${GREEN_COLOR}installing dependencies (${DEVICE_DESTINATION})...${END_COLOR}"
    run_command_on_device "sudo apt install python3 python3-pip python3-venv"
    run_command_on_device "cd ${DEVICE_DESTINATION}; python3 -m venv .venv; source .venv/bin/activate; pip3 install -r requirements.txt"
fi

CAPTURE_DATE=$(date '+%Y.%m.%d_%H.%M.%S')

echo -e "${GREEN_COLOR}starting...${END_COLOR}"
if [[ "${CAPTURE_MODE}" == "s" ]]; then
    run_command_on_device "cd ${DEVICE_DESTINATION}; source .venv/bin/activate; DISPLAY=${DEVICE_DISPLAY} python3 capture.py ${CAPTURE_APPLICATION_ARGUMENTS} -cm s" || true

    echo -e "${GREEN_COLOR}copying screenshot...${END_COLOR}"
    scp -P "${DEVICE_PORT}" "${DEVICE_USER}@${DEVICE_HOSTNAME}:${DEVICE_DESTINATION}/screenshot.png" "${OUTPUT_DIR}/screenshot_${CAPTURE_DATE}.png"

    echo -e "${GREEN_COLOR}copying png to jpg...${END_COLOR}"
    convert "${OUTPUT_DIR}/screenshot_${CAPTURE_DATE}.png" "${OUTPUT_DIR}/screenshot_${CAPTURE_DATE}.jpg"

    echo -e "${GREEN_COLOR}copying screenshot.png to clipboard...${END_COLOR}"
    xclip -selection clipboard -t image/png -i "${OUTPUT_DIR}/screenshot_${CAPTURE_DATE}.png"
else
    run_command_on_device "cd ${DEVICE_DESTINATION}; source .venv/bin/activate; DISPLAY=${DEVICE_DISPLAY} python3 capture.py ${CAPTURE_APPLICATION_ARGUMENTS}" || true

    echo -e "${GREEN_COLOR}copying video...${END_COLOR}"
    scp -P "${DEVICE_PORT}" "${DEVICE_USER}@${DEVICE_HOSTNAME}:${DEVICE_DESTINATION}/capture.avi" "${OUTPUT_DIR}/video_${CAPTURE_DATE}.avi"

    echo -e "${GREEN_COLOR}converting .avi to .mp4...${END_COLOR}"
    ffmpeg -i "${OUTPUT_DIR}/video_${CAPTURE_DATE}.avi" -hide_banner -loglevel error -c:v copy -c:a copy -y "${OUTPUT_DIR}/video_${CAPTURE_DATE}.mp4"

    echo -e "${GREEN_COLOR}converting .mp4 to .h264...${END_COLOR}"
    ffmpeg -i "${OUTPUT_DIR}/video_${CAPTURE_DATE}.avi" -hide_banner -loglevel error -an -vcodec libx264 -crf 23 "${OUTPUT_DIR}/video_${CAPTURE_DATE}.h264"
fi

echo -e "${BLUE_COLOR}\n:)${END_COLOR}"
