
gulp        = require "gulp"
Installer   = require "./installer"
Compiler    = require "./compiler"
Vendors     = require "./vendors"
misc        = require "./misc"
pkg         = require "../package.json"

# Compile the files
compiler = new Compiler(src: "./src", dest: "./app")
gulp.task "compileSettings", ->
  gulp.src("./src/settings.json").pipe(gulp.dest("./app"))
gulp.task "compileScripts", -> compiler.compileScripts()
gulp.task "compileStyles", -> compiler.compileStyles()
gulp.task "compileMarkup", -> compiler.compileMarkup()
gulp.task "compile", [
  "compileSettings"
  "compileScripts"
  "compileStyles"
  "compileMarkup"
]

# Nw tasks
NW_PACKAGE =
  "name": pkg.name
  "version": pkg.version
  "main": "index.html"
  "no-edit-menu": true
  "window":
    "toolbar": false
    "transparent": true
    "title": "Shadedit"
    "width": 600
    "height": 800
    "position": "right"
    "as_desktop": true

gulp.task "buildPackage", ->
  misc.writer(filename: "package.json", data: NW_PACKAGE, filter: misc.json())
    .pipe(gulp.dest("./app/"))

# Install the application
installer = new Installer()
gulp.task "buildApp", -> installer.buildApp()
# gulp.task "installMac", -> installer.install('osx')

vendors = new Vendors()
gulp.task "buildBower", -> vendors.buildBower()
gulp.task "buildVendors", -> vendors.buildVendors()
gulp.task "vendors", ["buildVendors", "buildBower"]

gulp.task "build", ["buildPackage", "compile", "vendors"]

gulp.task "watch", ["build"], ->
  for task, patterns of compiler.watchList
    for pattern in patterns
      gulp.watch pattern, [task]

gulp.task "default", ["watch"]
