
stream = require "stream"
gutil  = require "gulp-util"

#
# TODO
#
# # do
# writer(filename: "package.json", data: {name: "test", version: "0.0.1"})
#   .pipe(json())
#   .dest(gulp.dest("."))
#
# # instead of
# writer(filename: "package.json", data: {name: "test", version: "0.0.1"}, filter: json())
#

module.exports =

  writer: ({filename, data, filter}) ->
    src = stream.Readable({ objectMode: true })
    filter ?= (str) -> str
    data = filter(data)
    src._read = ->
      @push(new gutil.File(
        cwd: "", base: "", path: filename, contents: new Buffer(data)
      ))
      @push(null)
    src

  json: ({pretty, space} = {}) ->
    pretty ?= true
    space ?= '  '
    (string) ->
      JSON.stringify(string) unless pretty
      JSON.stringify(string, null, space)
