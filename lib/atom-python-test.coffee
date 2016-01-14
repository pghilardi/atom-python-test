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

  deactivate: ->
    @subscriptions.dispose()
    @atomPythonTestView.destroy()

  serialize: ->
    atomPythonTestViewState: @atomPythonTestView.serialize()

  runAllTests: ->
    console.log 'model: Run all tests'

    {BufferedProcess} = require 'atom'

    editor = atom.workspace.getActivePaneItem()
    file = editor?.buffer.file
    filePath = file?.path

    args = ['-s', filePath]
    command = 'py.test'
    stdout = (output) ->
      atomPythonTestView = AtomPythonTest.atomPythonTestView
      atomPythonTestView.addLine(output)
      atomPythonTestView.toggle()

    exit = (code) -> console.log("ps -ef exited with #{code}")
    process = new BufferedProcess({command, args, stdout, exit})
