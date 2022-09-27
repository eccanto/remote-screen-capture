[![code style: prettier](https://img.shields.io/badge/code_style-prettier-ff69b4.svg?style=flat-square)](https://github.com/prettier/prettier)

# Remote Screen Capture

Application to capture the screen as screenshots or videos remotely using Python, Bash, ssh and [Makeselft](https://makeself.io/).

# Table of contents

* [Overview](#overview)
* [Get started](#get-started)
  * [Build](#build)
  * [Installation](#installation)
  * [Run](#run)
    * [Record video](#record-video)
    * [Take screenshot](#take-screenshot)
    * [Record video when the process is running](#record-video-when-the-process-is-running)
    * [Help](#help)
* [Static code analysis tools](#static-code-analysis-tools)
  * [Python](#python)
  * [Shell](#shell)
* [License](#license)

# Overview

System flow:

![Sequence Diagram](documentation/sequence-diagram.png)

# Get Started

## Build

```bash
bash scripts/build.sh
```

The generated application is stored in the `build/` directory.

![Build](documentation/images/build.png)

## Installation

Install the application on your system (`/usr/bin/`).

```bash
bash scripts/install.sh
```

## Run

### Record video

```bash
screen_capture -- -h "<DEVICE_IP>" -m v
```

### Take screenshot

```bash
screen_capture -- -h "<DEVICE_IP>" -m s
```

### Record video when the process is running

```bash
screen_capture -- -h "<DEVICE_IP>" -m v -w "<PROCESS_NAME>"
```

### Help

```bash
$ screen_capture --

Usage: ./main.sh [ -h DEVICE_HOSTNAME ] [ -p DEVICE_PORT ] [ -u DEVICE_USER ] [ -d DEVICE_DISPLAY ] [ -m CAPTURE_MODE ] [ -w WAIT_PROCESS ]
  DEVICE_HOSTNAME: ssh hostname     [required]
  DEVICE_PORT:     ssh port         (default: 22)
  DEVICE_USER:     ssh username     (default: root)
  DEVICE_DISPLAY:  device DISPLAY   (default: :0)
  CAPTURE_MODE:    capture mode     (default: v (v: video, s: screenshot))
  WAIT_PROCESS:    Wait for process [required]
```

# Static code analysis tools

Checkers statically analyzes the code to find problems.

```bash
bash scripts/code_checkers.sh
```

## Python

- [black](https://github.com/psf/black): Black is the uncompromising Python code formatter.
- [isort](https://pycqa.github.io/isort/): Python utility / library to sort imports alphabetically, and automatically separated into sections and by type.
- [prospector](https://github.com/PyCQA/prospector): Prospector is a tool to analyse Python code and output information about errors, potential problems, convention violations and complexity.

  Tools executed by Prospector:
  - [pylint](https://github.com/PyCQA/pylint): Pylint is a Python static code analysis tool which looks for programming errors, helps enforcing a coding standard, sniffs for code smells and offers simple refactoring suggestions.
  - [bandit](https://github.com/PyCQA/bandit): Bandit is a tool designed to find common security issues.
  - [dodgy](https://github.com/landscapeio/dodgy): It is a series of simple regular expressions designed to detect things such as accidental SCM diff checkins, or passwords or secret keys hard coded into files.
  - [mccabe](https://github.com/PyCQA/mccabe): Complexity checker.
  - [mypy](https://github.com/python/mypy): Mypy is an optional static type checker for Python.
  - [pydocstyle](https://github.com/PyCQA/pydocstyle): pydocstyle is a static analysis tool for checking compliance with Python PEP 257.
  - [pycodestyle](https://pep8.readthedocs.io/en/release-1.7.x/): pycodestyle is a tool to check your Python code against some of the style conventions in PEP 8.
  - [pyflakes](https://github.com/PyCQA/pyflakes): Pyflakes analyzes programs and detects various errors.
  - [pyroma](https://github.com/regebro/pyroma): Pyroma is a product aimed at giving a rating of how well a Python project complies with the best practices of the Python packaging ecosystem, primarily PyPI, pip, Distribute etc, as well as a list of issues that could be improved.

## Shell

- [shellcheck](https://www.shellcheck.net/): Finds bugs in your shell scripts (bash).

# License

[MIT](./LICENSE)
