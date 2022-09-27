"""Screen capture package."""

import logging
from enum import Enum

import cv2
import mss
import numpy as np
from PIL import Image


class CaptureMode(Enum):
    """Available capture modes."""

    VIDEO = 'v'
    SCREENSHOT = 's'


def _get_screen_size_monitor(monitor_number):
    """Gets screen size by monitor number.

    :param monitor_number: The monitor number id.

    :returns: The monitor size as a tuple (width, height).
    """
    with mss.mss() as sct:
        mon = sct.monitors[monitor_number]
        return mon['width'], mon['height']


def _take_screenshot_monitor(monitor_number):
    """Takes screenshot by monitor.

    :param monitor_number: The monitor number id.

    :returns: The monitor screenshot as a PIL image.
    """
    with mss.mss() as sct:
        monitor_details = sct.monitors[monitor_number]
        screenshot_details = {
            'top': monitor_details['top'],
            'left': monitor_details['left'],
            'width': monitor_details['width'],
            'height': monitor_details['height'],
            'mon': monitor_number,
        }

        image_monitor = sct.grab(screenshot_details)
        return Image.frombytes(
            'RGB', image_monitor.size, image_monitor.bgra, 'raw', 'BGRX'
        )


def take_screenshot(monitor_number, output):
    """Takes a screenshot of the monitor and saves it to a file.

    :param monitor_number: The monitor number id.
    :param output: The output file path.
    """
    screen_size = _get_screen_size_monitor(monitor_number)

    logging.info(
        'capturing screenshot "%s" (size=%s) (Press "Ctrl+C to stop")',
        monitor_number,
        screen_size,
    )

    screenshot = _take_screenshot_monitor(monitor_number)
    screenshot.save(output)


def record_video(monitor_number, fps, output, callback_stop=None):
    """Records the monitor and saves it to a file.

    :param monitor_number: The monitor number id.
    :param fps: The video fps.
    :param output: The output file path.
    :callback_stop: A callback function that indicates when recording will stop.
    """
    screen_size = _get_screen_size_monitor(monitor_number)

    logging.info(
        'capturing screen "%s" (size=%s) (Press "Ctrl+C to stop")',
        monitor_number,
        screen_size,
    )

    fourcc = cv2.VideoWriter_fourcc(*'MJPG')
    output_video = cv2.VideoWriter(output, fourcc, fps, screen_size)
    try:
        while (callback_stop is None) or (not callback_stop()):
            frame = np.array(_take_screenshot_monitor(monitor_number))
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            output_video.write(frame)
    finally:
        logging.info('recording stopped')

        output_video.release()
        cv2.destroyAllWindows()
