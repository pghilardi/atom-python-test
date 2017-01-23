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

    addSpanTag: (text, class_to_add = "") ->
      new_text = "<span class=#{class_to_add}>#{text}</span>"
      return new_text

    colorStatus: (line) ->
      parts = line.split(" ")

      if parts[1] == "FAILED"
        colored_status = @addSpanTag(parts[1], class_to_add="failure-line")
        new_line = parts[0] + " " + colored_status

      else if parts[1] == "PASSED"
        colored_status = @addSpanTag(parts[1], class_to_add="success-line")
        new_line = parts[0] + " " + colored_status

      else
        new_line = line

      return new_line

    # TODO: add yellow if "no tests"
    colorLine: (line) ->
      if line.indexOf("failed") > -1 or line.indexOf("E") == 0
        new_line = @addSpanTag(line, class_to_add="failure-line")

      else if line.indexOf("passed") > -1
        new_line = @addSpanTag(line, class_to_add="success-line")

      else
        new_line = line

      return new_line

    # TODO: add empty line after "collected" and before "FAILURES/x passed in"
    addLine: (lines, do_coloring=false) ->
      for line in lines.split("\n")
        if line == ""
          continue

        @message = line

        if do_coloring
          if line.indexOf("====") > -1 or line.indexOf("E") == 0
            @message = @colorLine(line)

          else if line.indexOf("FAILED") > -1 or line.indexOf("PASSED") > -1
            @message = @colorStatus(line)

        @find(".output").append(@message + "\n")

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
      @addLine 'Running tests... \n \n'
      @panel.show()
