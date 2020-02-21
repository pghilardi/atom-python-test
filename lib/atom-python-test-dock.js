'use babel';

export default class AtomPythonTestViewDock {

  constructor(serializedState) {
    // Create root element
    this.element = document.createElement('div');
    this.element.classList.add('atom-python-test');
    this.tableResults = null;

    this.message = document.createElement('div');
    this.element.appendChild(this.message);
    this.message.innerHTML = "";
  }

  removeTable(){
    if (this.tableResults){
      this.element.removeChild(this.tableResults);
    }
  }

  createTable(){
    this.tableResults = document.createElement('table');
    this.tableResults.classList.add('tests');
    this.element.appendChild(this.tableResults);
  }

  createTableHeader() {
    header = this.tableResults.createTHead();
    var row = header.insertRow(0);

    testName = row.insertCell();
    testName.innerHTML = "Name";
    testTime = row.insertCell();
    testTime.innerHTML = "Time";
    testResult = row.insertCell();
    testResult.innerHTML = "Result";
    testResult = row.insertCell();
    testResult.innerHTML = "Exception";
  }

  printError(){
    this.removeTable(error);
    this.message.innerHTML = "There was an error executing the tests: " + error;
  }

  printOutput(junitOutput){

    console.log(junitOutput);

    numberOfTests = junitOutput.junit_info.tests.count !== undefined ? junitOutput.junit_info.tests.count : 0
    passedTests = junitOutput.junit_info.tests.passed !== undefined ? junitOutput.junit_info.tests.passed : 0
    failedTests = junitOutput.junit_info.tests.failure !== undefined ? junitOutput.junit_info.tests.failure : 0
    this.message.innerHTML = "<p><b>Summary: " + numberOfTests + " tests were executed: passed ("
      + passedTests + ") failed (" + failedTests + ")</b></p>";

    this.removeTable();
    this.createTable();

    suite = junitOutput.suites[0]

    for (index in suite.testCases){
      test = suite.testCases[index];
      testResult = this.tableResults.insertRow();

      if (test.type == 'passed'){
        cssClass = 'success-line';
      } else {
        cssClass = 'failure-line';
      }
      testNameCell = testResult.insertCell();
      testNameCell.innerHTML = `${test.name}`
      testNameCell.classList.add(cssClass);
      testNameCell.classList.add('row-name')

      testTimeCell = testResult.insertCell();
      testTimeCell.innerHTML = `${test.time}`
      testTimeCell.classList.add(cssClass);
      testNameCell.classList.add('row-time')

      testResultCell = testResult.insertCell();
      testResultCell.innerHTML = `${test.type}`
      testResultCell.classList.add(cssClass);
      testNameCell.classList.add('row-type')

      testExceptionCell = testResult.insertCell();

      if (test.type == 'failure'){
        exception = test.messages.values[0].value;

        lines = exception.split("\n");
        console.log(lines);

        testExceptionCell.innerHTML = `${exception}`
        testExceptionCell.classList.add(cssClass);
        testNameCell.classList.add('row-exception')

      }

    }

    this.createTableHeader();
  }

  getTitle() {
    // Used by Atom for tab text
    return 'Atom Python Test - Results';
  }

  getDefaultLocation() {
    // This location will be used if the user hasn't overridden it by dragging the item elsewhere.
    // Valid values are "left", "right", "bottom", and "center" (the default).
    return 'right';
  }

  getAllowedLocations() {
    // The locations into which the item can be moved.
    return ['left', 'right', 'bottom'];
  }

  getURI() {
    // Used by Atom to identify the view when toggling.
    return 'atom://atom-python-test-dock'
  }

  // Returns an object that can be retrieved when package is activated
  serialize() {
    return {
      deserializer: 'atom-python-test/AtomPythonTestViewDock'
    };
  }

  // Tear down any state and detach
  destroy() {
    this.element.remove();
  }

  getElement() {
    return this.element;
  }

}
