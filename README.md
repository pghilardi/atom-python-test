[![Build Status](https://travis-ci.org/pghilardi/atom-python-test.svg?branch=master)](https://travis-ci.org/pghilardi/atom-python-test)

## Description

* Run py.tests tests on Atom.

This project is on initial development. Feel free to contribute reporting bugs, improvements or creating pull requests.

## Requirements

* You need py.test installed to use this package: 

    ```
    pip install pytest
    ```

## Configuration

It's possible to customize a specific path to py.test in the settings of Atom Python Test. The default path is ```py.test```.

When using virtualenv, the recommended workflow is:
1) Activate your virtualenv on terminal.
2) Run atom editor, so this plug-in will get the virtualenv py.test version.

## Usage

1) Running all tests ```(Ctrl + Alt + T)```

2) Run test under cursor ```(Ctrl + Alt + C)```

![Run tests](https://cloud.githubusercontent.com/assets/1611808/14330216/ea1891e0-fc15-11e5-8190-696152c77c64.gif)

## To-Do List

- [x] Call py.test executable to run a python file.
- [x] Show the output on a bottom closable pane.
- [x] Add basic support to run test under cursor.
- [ ] Add support to run all project tests.
- [ ] Format the output and separate the output for each test.

