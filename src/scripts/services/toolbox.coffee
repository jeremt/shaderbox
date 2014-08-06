
{EventEmitter} = require "events"
gui = window.require "nw.gui"

class ToolboxService extends EventEmitter

  constructor: ->

  # Open the given file into its default application.
  editFile: (file) ->
    gui.Shell.openItem(file)

  # Open the given file into the OS file explorer.
  showFile: (file) ->
    gui.Shell.showItemInFolder(file)

  # Open a dialog the open the given file.
  openFile: (next, {folder} = {}) ->
    unless @fileInput
      @fileInput = window.document.createElement('input')
      @fileInput.type = 'file'
      @fileInput.accept = ".glsl"
    @fileInput.nwdirectory = folder ? false
    @fileInput.addEventListener("change", -> next(@value))
    @fileInput.click()

module.exports = ToolboxService
