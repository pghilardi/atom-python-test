AtomPythonTestView = require './atom-python-test-view'
{CompositeDisposable} = require 'atom'

module.exports = AtomPythonTest =
  atomPythonTestView: null
  modalPanel: null
  subscriptions: null

  config:
    pytestPath:
      type: 'string'
      default: 'py.test'
      title: 'Path to py.test'
      description: '''
      Optional. Set it if default values are not working for you or you want to use specific
      py.test version. For example: '/usr/local/bin/py.test'
      '''

  activate: (state) ->

    @atomPythonTestView = new AtomPythonTestView(state.atomPythonTestViewState)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-python-test:run-all-tests': => @runAllTests()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-python-test:run-test-under-cursor': => @runTestUnderCursor()

  deactivate: ->
    @subscriptions.dispose()
    @atomPythonTestView.destroy()

  serialize: ->
    atomPythonTestViewState: @atomPythonTestView.serialize()

  executePyTest: (args) ->
    {BufferedProcess} = require 'atom'

    @atomPythonTestView.clear()
    @atomPythonTestView.toggle()

    command = atom.config.get('atom-python-test.pytestPath')
    stdout = (output) ->
      atomPythonTestView = AtomPythonTest.atomPythonTestView
      atomPythonTestView.addLine(output)

    exit = (code) ->
      atomPythonTestView = AtomPythonTest.atomPythonTestView

    process = new BufferedProcess({command, args, stdout, exit})

  runTestUnderCursor: ->
    editor = atom.workspace.getActiveTextEditor()
    file = editor?.buffer.file
    filePath = file?.path
    selectedText = editor.getSelectedText()

    testLineNumber = editor.getCursorBufferPosition().row
    testIndentation = editor.indentationForBufferRow(testLineNumber)

    class_re = /class \w*\((\w*.*\w*)*\):/
    buffer = editor.buffer

    # Starts searching backwards from the test line until we find a class. This
    # guarantee that the class is a Test class, not an utility one.
    reversedLines = buffer.lines[0...testLineNumber].reverse()

    for line, classLineNumber in reversedLines
      startIndex = line.search(class_re)

      # We think that we have found a Test class, but this is guaranteed only if
      # the test indentation is greater than the class indentation.
      classIndentation = editor.indentationForBufferRow(classLineNumber)
      if startIndex != -1 and testIndentation > classIndentation
        endIndex = line.indexOf('(')
        startIndex = startIndex + 6
        className = line[startIndex...endIndex]
        filePath = filePath + '::' + className
        break

    re = /test(\w*|\W*)/;
    content = editor.buffer.lines[testLineNumber]
    endIndex = content.indexOf('(')
    startIndex = content.search(re)
    testName = content[startIndex...endIndex]

    if testName
      filePath = filePath + '::' + testName
      args = [filePath, '-s']
      @executePyTest(args)

  runAllTests: ->
    editor = atom.workspace.getActivePaneItem()
    file = editor?.buffer.file
    filePath = file?.path
    args = ['-s', filePath]
    @executePyTest(args)
