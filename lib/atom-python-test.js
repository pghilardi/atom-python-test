'use babel';

const { CompositeDisposable, Disposable } = require('atom');
const config = require('./config-schema.json');
const AtomPythonTestViewDock = require('./atom-python-test-dock');
const PytestExecutor = require('./executor/pytest-executor');

let subscriptions = null;
let dock = new AtomPythonTestViewDock();

const activate = () => {

    subscriptions = new CompositeDisposable(
      // Add an opener for our view.
      atom.workspace.addOpener(uri => {
        if (uri === 'atom://atom-python-test-dock') {
          return dock;
        }
      }),

      // Register command that toggles this view
      atom.commands.add('atom-workspace', {
        'atom-python-test:run-all-tests': () => {

          // Force the opening
          atom.workspace.open('atom://atom-python-test-dock');

          runAllTests();
        }
      }),

      atom.commands.add('atom-workspace', {
        'atom-python-test:run-test-under-cursor': () => {

          // Force the opening
          atom.workspace.open('atom://atom-python-test-dock');

          runTestUnderCursor();
        }
      }),

      atom.commands.add('atom-workspace', {
        'atom-python-test:toggle-test-results': () => {
          pane = atom.workspace.toggle('atom://atom-python-test-dock')
        }
      }),

      // Destroy any ActiveEditorInfoViews when the package is deactivated.
      new Disposable(() => {
        atom.workspace.getPaneItems().forEach(item => {
          if (item instanceof AtomPythonTestViewDock) {
            item.destroy();
          }
        });
      })
  );
};

const deactivate = () => {
    subscriptions.dispose();
};

const runAllTests = () => {
  editor = atom.workspace.getActivePaneItem()
  file = editor.buffer.file
  filePath = file.path

  executor = new PytestExecutor(dock);
  additionalArgs = atom.config.get('atom-python-test.additionalArgs').toString();
  pythonExecutableDirectory = atom.config.get('atom-python-test.pythonExecutableDirectory').toString();
  executor.executePyTest(filePath, pythonExecutableDirectory, additionalArgs);
};

const runTestUnderCursor = () => {
  const editor = atom.workspace.getActiveTextEditor();
  const file = editor != null ? editor.buffer.file : undefined;
  let filePath = file != null ? file.path : undefined;
  const selectedText = editor.getSelectedText();

  const testLineNumber = editor.getCursorBufferPosition().row;
  const testIndentation = editor.indentationForBufferRow(testLineNumber);

  const class_re = /class \w*\((\w*.*\w*)*\):/;
  const buffer = editor.buffer;

  // Starts searching backwards from the test line until we find a class. This
  // guarantee that the class is a Test class, not an utility one.
  const reversedLines = buffer.getLines().slice(0, testLineNumber).reverse();

  for (let i = 0; i < reversedLines.length; i++) {
    var endIndex;
    const line = reversedLines[i];
    const isClassLine = line.startsWith("class");

    const classLineNumber = testLineNumber - i - 1;

    // We think that we have found a Test class, but this is guaranteed only if
    // the test indentation is greater than the class indentation.
    const classIndentation = editor.indentationForBufferRow(classLineNumber);
    // if startIndex != -1 and testIndentation > classIndentation
    if (isClassLine && (testIndentation > classIndentation)) {
      if (line.includes('(')) {
        endIndex = line.indexOf('(');
      } else {
        endIndex = line.indexOf(':');
      }
      const className = line.slice(6, endIndex);
      filePath = filePath + '::' + className;
      break;
    }
  }

  const re = /test(\w*|\W*)/;
  const content = editor.buffer.getLines()[testLineNumber];
  endIndex = content.indexOf('(');
  const startIndex = content.search(re);
  const testName = content.slice(startIndex, endIndex);

  if (testName) {
    filePath = filePath + '::' + testName;
    additionalArgs = atom.config.get('atom-python-test.additionalArgs');
    pythonExecutableDirectory = atom.config.get('atom-python-test.pythonExecutableDirectory')
    executor = new PytestExecutor(dock);
    executor.executePyTest(filePath, pythonExecutableDirectory, additionalArgs);
  }
}

module.exports = {
  activate,
  deactivate,
  config,
  subscriptions
};
