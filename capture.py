"""Screen capture command line application.

Date:   2022-09-22
Author: Erik Ccanto
"""

import logging
import time
from pathlib import Path

import click
import coloredlogs
import psutil

from src.screen_capture import CaptureMode, record_video, take_screenshot


DEFAULT_FPS = 10.0
DEFAULT_MONITOR = 0
DEFAULT_VIDEO_OUTPUT = Path('capture.avi')
DEFAULT_SCREENSHOT_OUTPUT = Path('screenshot.png')


def get_process(process_name):
    """Gets a psutil process by name.

    :param process_name: The process name.

    :returns: psutil process instance.
    """
    return next(
        (
            process_item
            for process_item in psutil.process_iter()
            if process_item.name() == process_name
        ),
        None,
    )


@click.command()
@click.option(
    '-f', '--fps', help=f'Video fps (default: {DEFAULT_FPS}).', default=DEFAULT_FPS
)
@click.option('-p', '--process', help='Wait for process.')
@click.option(
    '-m',
    '--monitor',
    help=f'Monitor number (default: {DEFAULT_MONITOR}).',
    type=int,
    default=DEFAULT_MONITOR,
)
@click.option(
    '-cm',
    '--capture_mode',
    type=click.Choice([choice.value for choice in CaptureMode]),
    help=f'Capture mode (choices: {[choice.value for choice in CaptureMode]}, default: {CaptureMode.VIDEO.value})',
    default=CaptureMode.VIDEO.value,
    callback=lambda _context, _parameter, value: next(
        (mode for mode in CaptureMode if mode.value == value), None
    ),
)
def main(monitor, fps, process, capture_mode):
    """Captures monitor screenshot or video."""
    coloredlogs.install(
        fmt='%(asctime)s,%(msecs)03d %(hostname)s %(name)s[%(process)d] %(levelname)s %(message)s',
        level='INFO',
    )

    for output in (DEFAULT_VIDEO_OUTPUT, DEFAULT_SCREENSHOT_OUTPUT):
        if output.exists():
            output.unlink()

    if process:
        logging.info('waiting for "%s"...', process)

        while not get_process(process):
            time.sleep(0.1)

    if capture_mode == CaptureMode.VIDEO:
        record_video(
            monitor,
            fps,
            str(DEFAULT_VIDEO_OUTPUT),
            callback_stop=(lambda: get_process(process) is None) if process else None,
        )
    elif capture_mode == CaptureMode.SCREENSHOT:
        take_screenshot(monitor, str(DEFAULT_SCREENSHOT_OUTPUT))


if __name__ == '__main__':
    main()  # pylint: disable=no-value-for-parameter
