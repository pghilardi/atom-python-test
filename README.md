[![Build Status](https://travis-ci.org/pghilardi/atom-python-test.svg?branch=master)](https://travis-ci.org/pghilardi/atom-python-test)

## Description

* Run py.tests and unitest.TestCase tests on Atom. 

## Requirements

* You need py.test installed to use this package:

    ```
    pip install pytest
    ```

When using virtualenv, the recommended workflow is:

* Activate your virtualenv on terminal.
* Run atom editor, so this plug-in will get py.test from virtualenv (or use atom-python-virtualenv plug-in).

## Usage

1) Running all tests ```(Ctrl + Alt + T)```

2) Run test under cursor ```(Ctrl + Alt + C)```

3) Hide the execution panel ```(Ctrl + Alt + H)```

![Run tests](https://cloud.githubusercontent.com/assets/1611808/14330216/ea1891e0-fc15-11e5-8190-696152c77c64.gif)

The plug-in supports to color the output: tests passed in green and failed in red and also supports to add more execution parameters in the settings.

## To-Do List

- [x] Call py.test executable to run a python file.
- [x] Show the output on a bottom closable pane.
- [x] Add basic support to run test under cursor.
- [x] Format the output and separate the output for each test.
- [ ] Add support to run all project tests.

This project is on initial development. Feel free to contribute reporting bugs, improvements or creating pull requests.
