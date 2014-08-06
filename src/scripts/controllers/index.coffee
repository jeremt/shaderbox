
path = require "path"

module.exports = (ngModule) ->

  #
  # Toolbar Ctrl
  #
  ngModule.controller "ToolbarCtrl", class

    @$inject = [
      "$scope"
      "ToolboxService"
      "LoaderService"
      "RendererService"
    ]

    constructor: (@scope, @toolbox, @loader, @renderer) ->
      @scope.shapes = [
        'Plane'
        'Sphere'
      ]
      @scope.playing = true

    open: ->
      @toolbox.openFile((file) =>
        @loader.load(file, type: 'fragment')
        @renderer.loadShader()
      )

    tooglePlay: ->
      @renderer.tooglePlay()
      @scope.playing = not @scope.playing

    changeShape: -> @renderer.changeShape()
    changeTexture: -> @renderer.changeTexture()
    resetCamera: -> @renderer.resetCamera()

    show: -> @scope.visible = true
    hide: -> @scope.visible = false
