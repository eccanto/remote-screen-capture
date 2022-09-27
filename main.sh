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
DEVICE_DESTINATION=/root/video_capturer

CAPTURE_MODE=v

INSTALL_REQUIREMENTS=false

RUN_DIR=${USER_PWD:-$(pwd)}
OUTPUT_DIR="${RUN_DIR}/captures/"

CAPTURE_APPLICATION_ARGUMENTS="-m 0"

function print_usage() {
    echo "Usage: $0 [ -h DEVICE_HOSTNAME ] [ -p DEVICE_PORT ] [ -u DEVICE_USER ] [ -m CAPTURE_MODE ] [ -w WAIT_PROCESS ] [ -i ]"
    echo " default DEVICE_PORT: 22"
    echo " default DEVICE_USER: root"
    echo " default CAPTURE_MODE: v (v: video, s: screenshot)"
    echo " -i install requirements [flag]"
}

function parse_arguments() {
    while getopts "h:p:u:m:w:i" flag; do
        case $flag in
            h) DEVICE_HOSTNAME=$OPTARG;;
            p) DEVICE_PORT=$OPTARG;;
            u) DEVICE_USER=$OPTARG;;
            i) INSTALL_REQUIREMENTS=true;;
            m) CAPTURE_MODE=$OPTARG;;
            w) WAIT_PROCESS=$OPTARG;;
            *) print_usage; exit 1;;
        esac
    done
}

function run_command_on_device() {
    declare -r command=$1

    ssh -p "${DEVICE_PORT}" "${DEVICE_USER}"@"${DEVICE_HOSTNAME}" "${command}"
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

if ! command -v ffmpeg &> /dev/null; then
    sudo apt install -y ffmpeg
fi

mkdir -p "${OUTPUT_DIR}"

echo -e "${GREEN_COLOR}connecting to '${DEVICE_USER}@${DEVICE_HOSTNAME}:${DEVICE_PORT}'...${END_COLOR}"

run_command_on_device "mkdir -p ${DEVICE_DESTINATION}"
scp -P "${DEVICE_PORT}" {capturer.py,requirements.txt} "${DEVICE_USER}"@"${DEVICE_HOSTNAME}":"${DEVICE_DESTINATION}"

if [[ "${INSTALL_REQUIREMENTS}" == "true" ]]; then
    run_command_on_device "apt install python3 python3-pip"
    run_command_on_device "cd ${DEVICE_DESTINATION}; pip3 install -r requirements.txt"
fi

CAPTURE_DATE=$(date '+%Y.%m.%d_%H.%M.%S')

if [[ "${CAPTURE_MODE}" == "s" ]]; then
    run_command_on_device "cd ${DEVICE_DESTINATION}; DISPLAY=${DEVICE_DISPLAY} python3 capturer.py ${CAPTURE_APPLICATION_ARGUMENTS} -cm s"
    scp -P "${DEVICE_PORT}" "${DEVICE_USER}@${DEVICE_HOSTNAME}:${DEVICE_DESTINATION}/screenshot.png" "${OUTPUT_DIR}/${CAPTURE_DATE}_screenshot.png"

    echo -e "${GREEN_COLOR}copying screenshot.png to clipboard...${END_COLOR}"
    xclip -selection clipboard -t image/png -i "${OUTPUT_DIR}/${CAPTURE_DATE}_screenshot.png"
else
    run_command_on_device "cd ${DEVICE_DESTINATION}; DISPLAY=${DEVICE_DISPLAY} python3 capturer.py ${CAPTURE_APPLICATION_ARGUMENTS}"
    scp -P "${DEVICE_PORT}" "${DEVICE_USER}@${DEVICE_HOSTNAME}:${DEVICE_DESTINATION}/capture.avi" "${OUTPUT_DIR}/${CAPTURE_DATE}_capture.avi"

    echo -e "${GREEN_COLOR}converting .avi to .mp4...${END_COLOR}"
    ffmpeg -i "${OUTPUT_DIR}/${CAPTURE_DATE}_capture.avi" -hide_banner -loglevel error -c:v copy -c:a copy -y "${OUTPUT_DIR}/${CAPTURE_DATE}_capture.mp4"

    echo -e "${GREEN_COLOR}converting .mp4 to .h264...${END_COLOR}"
    ffmpeg -i "${OUTPUT_DIR}/${CAPTURE_DATE}_capture.avi" -hide_banner -loglevel error -an -vcodec libx264 -crf 23 "${OUTPUT_DIR}/${CAPTURE_DATE}_capture.h264"
fi

echo -e "${BLUE_COLOR}\n:)${END_COLOR}"
