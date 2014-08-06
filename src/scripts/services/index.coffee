
module.exports = (ngModule) ->

  ngModule.service "RendererService", require "./renderer"
  ngModule.service "LoaderService", require "./loader"
  ngModule.service "ToolboxService", require "./toolbox"
