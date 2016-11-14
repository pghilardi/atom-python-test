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
          @button outlet: 'clearBtn', class: 'btn inline-block-tight right', click: 'clear', style: 'float: right', =>
            @span class: 'icon icon-trashcan'
          @button outlet: 'clearBtn', class: 'btn inline-block-tight right', click: 'clear', style: 'float: right', =>
            @span class: 'icon icon-history'
        @pre class: 'output', outlet: 'output'
        # TODO: create history button

    initialize: ->
      @panel ?= atom.workspace.addBottomPanel(item: this)
      @message = ""
      @panel.hide()
    # TODO: create history field to store previous results

    createTimestamp: ->
      today = new Date
      dd = today.getDate()
      #The value returned by getMonth is an integer between 0 and 11, referring 0 to January, 1 to February, and so on.
      mm = today.getMonth() + 1
      yyyy = today.getFullYear()
      if dd < 10
        dd = '0' + dd
      if mm < 10
        mm = '0' + mm
      today = mm + '-' + dd + '-' + yyyy
      return today

    # TODO: move html taggin to a separate function
    # TODO: refactor the error coloring
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
      virtual_console = @find(".output")[0]
      while virtual_console.firstChild
        virtual_console.removeChild(virtual_console.firstChild)


    finish: ->
      console.log('finish')

    destroy: ->
      @panel.hide()

    reset: -> @message = defaultMessage

    toggle: ->
      @find(".output").height(300)
      @addLine @createTimestamp()
      @addLine '\nRunning tests... \n \n'
      @panel.show()
