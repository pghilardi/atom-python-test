## Description

* Run py.tests tests on Atom.

## Requirements

* You need py.test installed to use this package: 

    ```
    pip install pytest
    ```
    
## Usage

1) Running all tests (Ctrl + Alt + T):

![alt text](https://github.com/pghilardi/atom-python-test/blob/master/images/all_tests.png "Run all tests")

![alt text](https://github.com/pghilardi/atom-python-test/blob/master/images/run_all_output.png "Output")

2) Run test under cursor (Ctrl + Alt + C):

![alt text](https://github.com/pghilardi/atom-python-test/blob/master/images/under_cursor.png "Run test under cursor")

## To-Do List
- [x] Call py.test executable to run a python file.
- [x] Show the output on a bottom closable pane.
- [x] Add basic support to run test under cursor.
- [ ] Add support to run all project tests.
- [ ] Format the output and separate the output for each test.
