{$, ScrollView} = require 'atom-space-pen-views'

module.exports =
  class AtomPythonTestView extends ScrollView

    message: ''
    maximized: false

    @content: ->
      @div class: 'atom-python-test-view native-key-bindings', outlet: 'atomTestView', tabindex: -1, overflow: "auto", =>
        @div class: 'btn-toolbar', outlet:'toolbar', =>
          @button outlet: 'closeBtn', class: 'btn inline-block-tight right', click: 'destroy', style: 'float: right', =>
            @span class: 'icon icon-x'
        @pre class: 'output', outlet: 'output'

    initialize: ->
      @panel ?= atom.workspace.addBottomPanel(item: this)
      @message = ""
      @panel.hide()

    addLine: (line) ->
      if  true == /.*\d+.failed.*(passed)?.in.*seconds.*/i.test(line)
        array_o_lines = line.split("\n")
        for l in array_o_lines
          if l.indexOf("====") > -1 or l.indexOf("E") == 0
            @message = "<span style='color: red'>" + l + "</span>"
          else
            @message = "<span style='color: white'>" + l + "</span>"
          @find(".output").append(@message + "\n")
      else if true == /.*\d+.passed.in.*seconds.*/i.test(line)
        @message = "<span style='color: green'>" + line + "</span>"
        @find(".output").append(@message)
      else
        @find(".output").append(line)


    clear: ->
      @message = ''

    finish: ->
      console.log('finish')

    destroy: ->
      @panel.hide()

    reset: -> @message = defaultMessage

    toggle: ->
      @find(".output").height(300)
      @find(".output").innerHTML = ""
      @addLine 'Running tests... \n \n'
      @panel.show()
