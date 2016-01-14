{$, ScrollView} = require 'atom-space-pen-views'

module.exports =
  class AtomPythonTestView extends ScrollView

    message: ''

    @content: ->
      @div =>
        @pre class: 'output'

    initialize: ->
      super
      @panel ?= atom.workspace.addRightPanel(item: this)
      @panel.hide()

    addLine: (line) ->
      @message += line
      @find(".output").text(@message)
      @show()

    finish: ->
      console.log('finish')

    reset: -> @message = defaultMessage

    toggle: ->
      @panel.show()
