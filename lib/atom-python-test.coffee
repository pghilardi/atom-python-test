AtomPythonTestView = require './atom-python-test-view'
{CompositeDisposable} = require 'atom'

module.exports = AtomPythonTest =
  atomPythonTestView: null
  modalPanel: null
  subscriptions: null

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

    command = 'py.test'
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

    filePath = filePath + '::' + selectedText
    args = [filePath, '-s']
    @executePyTest(args)

  runAllTests: ->
    editor = atom.workspace.getActivePaneItem()
    file = editor?.buffer.file
    filePath = file?.path
    args = ['-s', filePath]
    @executePyTest(args)
