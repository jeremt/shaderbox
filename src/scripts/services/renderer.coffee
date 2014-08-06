
{EventEmitter} = require "events"

class RendererService extends EventEmitter

  @$inject = ["LoaderService"]

  WIDTH = window.innerWidth
  HEIGHT = window.innerHeight - 80
  FOV = 45
  NEAR = 0.1
  FAR = 100.0

  DURATION = 2.0

  GEOMETRIES = [
    new window.THREE.PlaneGeometry(2.0 * (WIDTH / HEIGHT), 2.0)
    new window.THREE.BoxGeometry(1.0, 1.0, 1.0)
    new window.THREE.CylinderGeometry(0.5, 0.5, 1.5, 20)
    new window.THREE.SphereGeometry(0.5, 20, 20)
    new window.THREE.TorusGeometry(0.5, 0.2, 20, 20)
  ]

  constructor: (@loader) ->

    @slider = window.document.getElementById('slider')

    @scene = new window.THREE.Scene()

    @resetCamera()

    @_playing = true

    @material = new window.THREE.ShaderMaterial(
      uniforms:
        texture:
          type: "t"
          value: null
        color:
          type: "c"
          value: new window.THREE.Color(0xffffff)
        resolution:
          type: "v2"
          value: new window.THREE.Vector2(WIDTH, HEIGHT)
        rate:
          type: "f"
          value: 0.0
      vertexShader: @loader.vertexShader
      fragmentShader: @loader.fragmentShader
    )
    @_currentIndex = 0
    @changeShape(@_currentIndex)
    @changeTexture()

    @renderer = new window.THREE.WebGLRenderer(alpha: true)
    @renderer.setSize(WIDTH, HEIGHT)

    window.document.body.appendChild(@renderer.domElement)

    window.addEventListener('resize', =>

      WIDTH = window.innerWidth
      HEIGHT = window.innerHeight - 80
      @renderer.setSize(WIDTH, HEIGHT)

      @camera.aspect = WIDTH/HEIGHT
      @camera.updateProjectionMatrix()
      angle = FOV * Math.PI / 180
      @camera.position.z = 1.0 / Math.tan(angle / 2.0)

      @material.uniforms.resolution.value = new window.THREE.Vector2(WIDTH, HEIGHT)

    )

    previousTime = 0
    currentTime = 0
    do =>
      window.requestAnimationFrame(arguments.callee)

      now = new Date().getTime()
      dt = now - (previousTime || now)
      previousTime = now
      if currentTime > DURATION
        currentTime = 0.0
      if @_playing
        @material.uniforms.rate.value = currentTime / DURATION
        @slider.style.width = "#{100 * currentTime / DURATION}%"
        currentTime += dt / 1000.0
      @controls.update()
      @renderer.render(@scene, @camera)

  tooglePlay: ->
    @_playing = not @_playing

  resetCamera: ->
    @camera = new window.THREE.PerspectiveCamera(FOV, WIDTH / HEIGHT, NEAR, FAR)
    angle = FOV * Math.PI / 180
    @camera.position.z = 1.0 / Math.tan(angle / 2.0)
    @controls = new window.THREE.OrbitControls(@camera)

  changeShape: (index) ->
    index ?= ++@_currentIndex
    if @mesh
      @scene.remove(@mesh)
    @mesh = new window.THREE.Mesh(GEOMETRIES[index % (GEOMETRIES.length)], @material)
    @scene.add(@mesh)

  changeTexture: ->
    @material.uniforms.texture.value = window.THREE.ImageUtils.loadTexture(
      "http://lorempixel.com/#{WIDTH}/#{HEIGHT}"
    )

  loadShader: (source) ->
    @material.fragmentShader = source ? @loader.fragmentShader
    @material.needsUpdate = true

module.exports = RendererService
