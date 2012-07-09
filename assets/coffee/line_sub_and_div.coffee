class Example
  constructor: (width = 200, height = 200) ->
    @canvas  = $("<canvas width='#{width}' height='#{height}'></canvas>").appendTo($("#line_divided"))[0]
    @context = @canvas.getContext("2d")

    @mouse  = new Vector(0, 0)
    @center = new Vector(@canvas.width / 2, @canvas.height / 2)

    @canvas.addEventListener "mousemove", @mouseMoved, false

  mouseMoved: (event) =>
    @mouse.x = event.offsetX
    @mouse.y = event.offsetY

  start: -> #do @loop

  loop: =>
    requestAnimationFrame @loop

    do @clearScreen

    target = Vector.sub @mouse, @center

    # Let's scale the line to half of its size
    target.div(2)

    @context.translate @center.x, @center.y
    do @context.beginPath
    @context.lineTo target.x, target.y
    do @context.closePath
    @context.translate 0, 0

    @context.strokeStyle = "#000"
    do @context.stroke

  clearScreen: ->
    @context.clearRect 0, 0, @canvas.width, @canvas.height

window.LineSubAndDiv = Example
