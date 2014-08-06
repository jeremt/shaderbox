
path = require "path"
gutil = require "gulp-util"
NwBuilder = require "node-webkit-builder"
Builder = require "./builder"

class Installer extends Builder

  DEFAULT_OPTIONS =
    src: "./app"
    dest: "./build"
    platforms: ["win", "osx", "linux32", "linux64"]

  constructor: ({@src, @dest} = {}) ->
    Builder.call(@)
    @src ?= DEFAULT_OPTIONS.src
    @dest ?= DEFAULT_OPTIONS.dest

  buildApp: ({platforms} = {}) ->
    platforms ?= DEFAULT_OPTIONS.platforms
    new NwBuilder(
      # version: "0.9.2"
      files: [path.join(@src, "**")]
      platforms: platforms ? DEFAULT_OPTIONS.platforms
      macIcns: "./icon.icns"
    ).on('log', (msg) ->
      gutil.log('node-webkit-builder', msg)
    ).build().catch(@handleError)

module.exports = Installer