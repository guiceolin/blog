class Ball
  MAX_SPEED = 10

  constructor: (@x, @y) ->
    @position = new Vector x, y
    @velocity = new Vector 0, 0
    @radius = 10

  update: (mouse) ->
    direction = Vector.sub mouse, @position
    direction.normalize()
    direction.div 2

    acceleration = direction

    @velocity.add acceleration
    @velocity.limit MAX_SPEED
    @position.add @velocity

  draw: (context) ->
    # Draws the ball on the screen
    context.fillStyle = "#fff"
    context.beginPath()
    context.fillCircle @position.x, @position.y, @radius
    context.closePath()

class Example
  constructor: (container, width = 200, height = 200) ->
    @canvas  = $("<canvas width='#{width}' height='#{height}'></canvas>").appendTo($(container))[0]
    @context = @canvas.getContext("2d")

    random = (min, max) -> Math.random() * (max - min) + min

    @balls = []
    for index in [1..10]
      @balls.push new Ball(random(0, @canvas.width), random(0, @canvas.height))

    @mouse = new Vector 0, 0

    # Updates the mouse position when it moves
    @canvas.addEventListener "mousemove", @mouseMoved, false

  mouseMoved: (event) =>
    @mouse.x = event.offsetX
    @mouse.y = event.offsetY

  start: -> do @loop

  loop: =>
    requestAnimationFrame @loop

    do @clearScreen

    for ball in @balls
      ball.update(@mouse)
      ball.draw(@context)

  clearScreen: ->
    @context.fillStyle = "rgba(14, 14, 14, 0.2)"
    @context.fillRect 0, 0, @canvas.width, @canvas.height

window.AccelerationTowardsMouse = Example
