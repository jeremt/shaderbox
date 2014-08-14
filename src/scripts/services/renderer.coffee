
{EventEmitter} = require "events"

class RendererService extends EventEmitter

  @$inject = ["LoaderService"]

  FOV = 45
  NEAR = 0.1
  FAR = 100.0

  DURATION = 2.0

  constructor: (@loader) ->

    @rendererElement = window.document.getElementById('renderer')
    @sliderElement = window.document.getElementById('slider')

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
          value: new window.THREE.Vector2(@getWidth(), @getHeight())
        rate:
          type: "f"
          value: 0.0
      vertexShader: @loader.vertexShader
      fragmentShader: @loader.fragmentShader
    )

    light = new window.THREE.PointLight(0xffffff)
    light.position.set(-1,1,1)
    @scene.add(light)

    @_currentIndex = 0
    @changeShape(@_currentIndex)
    @changeTexture()

    @renderer = new window.THREE.WebGLRenderer(alpha: true)
    @renderer.setSize(@getWidth(), @getHeight())

    @rendererElement.appendChild(@renderer.domElement)

    window.addEventListener('resize', =>

      @renderer.setSize(@getWidth(), @getHeight())

      @camera.aspect = @getAspect()
      @camera.updateProjectionMatrix()
      angle = FOV * Math.PI / 180
      @camera.position.z = 1.0 / Math.tan(angle / 2.0)

      @material.uniforms.resolution.value = new window.THREE.Vector2(@getWidth(), @getHeight())

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
        @sliderElement.style.width = "#{100 * currentTime / DURATION}%"
        currentTime += dt / 1000.0
      @renderer.render(@scene, @camera)

  tooglePlay: ->
    @_playing = not @_playing

  resetCamera: ->
    @camera = new window.THREE.PerspectiveCamera(FOV, @getAspect(), NEAR, FAR)
    angle = FOV * Math.PI / 180
    @camera.position.z = 1.0 / Math.tan(angle / 2.0)

  getWidth: -> @rendererElement.clientWidth
  getHeight: -> @rendererElement.clientHeight
  getAspect: -> @getWidth() / @getHeight()

  changeShape: (index) ->
    index ?= ++@_currentIndex
    if @mesh
      @scene.remove(@mesh)

    geometry = switch index % 5
      when 0 then new window.THREE.PlaneGeometry(2.0 * @getAspect(), 2.0)
      when 1 then new window.THREE.BoxGeometry(1.0, 1.0, 1.0)
      when 2 then new window.THREE.CylinderGeometry(0.5, 0.5, 1.5, 20)
      when 3 then new window.THREE.SphereGeometry(0.5, 20, 20)
      when 4 then new window.THREE.TorusGeometry(0.5, 0.2, 20, 20)

    @mesh = new window.THREE.Mesh(geometry, @material)
    @scene.add(@mesh)

  changeTexture: ->
    @material.uniforms.texture.value = window.THREE.ImageUtils.loadTexture(
      "http://lorempixel.com/#{@getWidth()}/#{@getHeight()}"
    )

  loadShader: (source) ->
    @material.fragmentShader = source ? @loader.fragmentShader
    @material.needsUpdate = true

module.exports = RendererService
