
fs             = require "fs"
{EventEmitter} = require "events"

class LoaderService extends EventEmitter

  constructor: ->
    @load("../examples/vertex.glsl", type: "vertex")
    @load("../examples/basic.glsl", type: "fragment")

  load: (file, {type} = {}) ->
    return unless fs.existsSync(file)
    if type is "vertex"
      @vertexShader = fs.readFileSync(file).toString()
    else
      @fragmentShader = fs.readFileSync(file).toString()

module.exports = LoaderService
