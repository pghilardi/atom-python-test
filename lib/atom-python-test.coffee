AtomPythonTestView = require './atom-python-test-view'
{CompositeDisposable} = require 'atom'

module.exports = AtomPythonTest =

  atomPythonTestView: null

  modalPanel: null

  subscriptions: null

  config:
    executeDocTests:
      type: 'boolean'
      default: false
      title: 'Execute doc tests on test runs'
    additionalArgs:
      type: 'string'
      default: ''
      title: 'Additional arguments for pytest command line'
    outputColored:
      type: 'boolean'
      default: false
      title: 'Color the output'
    onlyShowPanelOnFailure:
      type: 'boolean'
      default: false
      title: 'Only show test panel on test failure'

  activate: (state) ->

    @atomPythonTestView = new AtomPythonTestView(state.atomPythonTestViewState)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-python-test:run-all-tests': => @runAllTests()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-python-test:run-test-under-cursor': => @runTestUnderCursor()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-python-test:close-panel': => @closePanel()
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-python-test:run-all-project-tests': => @runAllProjectTests()


  deactivate: ->
    @subscriptions.dispose()
    @atomPythonTestView.destroy()

  serialize: ->
    atomPythonTestViewState: @atomPythonTestView.serialize()

  executePyTest: (filePath) ->
    {BufferedProcess} = require 'atom'

    @tmp = require('tmp');

    @atomPythonTestView.clear()

    # display of panel depends on onlyShowPanelOnFailure
    @onlyShowPanelOnFailure = atom.config.get('atom-python-test.onlyShowPanelOnFailure')
    if @onlyShowPanelOnFailure
      @atomPythonTestView.destroy()
    else
      @atomPythonTestView.toggle()

    stdout = (output) ->
      atomPythonTestView = AtomPythonTest.atomPythonTestView
      doColoring = atom.config.get('atom-python-test.outputColored')
      atomPythonTestView.addLine output, doColoring

    exit = (code) =>
      atomPythonTestView = AtomPythonTest.atomPythonTestView

      if @onlyShowPanelOnFailure and atomPythonTestView.message.includes("success-line") #pytest retrun succes
        statusBar = document.getElementsByClassName('status-bar')[0]
        statusBar.style.background = "green"
        setTimeout ->
          statusBar.style.background = "" # show green status bar while one second  on sucess
        , 500
      else
        atomPythonTestView.toggle() #show panel if pytest is not success

      junitViewer = require('junit-viewer')
      parsedResults = junitViewer.parse(AtomPythonTest.testResultsFilename.name)

      if parsedResults.junit_info.tests.error > 0 and code != 0
        atomPythonTestView.addLine "An error occured while executing py.test.
          Check if py.test is installed and is in your path."

    @testResultsFilename = @tmp.fileSync({prefix: 'results', keep : true, postfix: '.xml'});

    executeDocTests = atom.config.get('atom-python-test.executeDocTests')

    command = 'python'
    args = ['-m', 'pytest', filePath, '--junit-xml=' + @testResultsFilename.name]

    if executeDocTests
      args.push '--doctest-modules'

    additionalArgs = atom.config.get('atom-python-test.additionalArgs')
    if additionalArgs
      args = args.concat additionalArgs.split " "

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
    reversedLines = buffer.getLines()[0...testLineNumber].reverse()

    for line, i in reversedLines
      # startIndex = line.search(class_re)
      isClassLine = line.startsWith("class")

      classLineNumber = testLineNumber - i - 1

      # We think that we have found a Test class, but this is guaranteed only if
      # the test indentation is greater than the class indentation.
      classIndentation = editor.indentationForBufferRow(classLineNumber)
      # if startIndex != -1 and testIndentation > classIndentation
      if isClassLine and testIndentation > classIndentation
        if line.includes('(')
          endIndex = line.indexOf('(')
        else
          endIndex = line.indexOf(':')
        className = line[6...endIndex]
        filePath = filePath + '::' + className
        break

    re = /test(\w*|\W*)/;
    content = editor.buffer.getLines()[testLineNumber]
    endIndex = content.indexOf('(')
    startIndex = content.search(re)
    testName = content[startIndex...endIndex]

    if testName
      filePath = filePath + '::' + testName
      @executePyTest(filePath)

  runAllTests: () ->
    editor = atom.workspace.getActivePaneItem()
    file = editor?.buffer.file
    filePath = file?.path
    @executePyTest(filePath)

  runAllProjectTests: () ->
    editor = atom.workspace.getActivePaneItem()
    fullPath = atom.project.relativizePath(editor.getBuffer().file.path)
    @executePyTest(fullPath[0])

  closePanel: ->
      @atomPythonTestView.destroy()
