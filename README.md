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

## configuration

On settings you can configure the path to the python executable, so you can choose your python executable from virtualenv, miniconda, pyenv, etc. You can configure additionalArgs to the pytest
command line executor too.

## Usage

1) Running all tests ```(Ctrl + Alt + T)```

2) Run test under cursor ```(Ctrl + Alt + C)```

3) Toggle (on/off) the tests panel ```(Ctrl + Alt + H)```
