random = (min, max) -> Math.random() * (max - min) + min

class Ball
  MAX_SPEED = 15

  constructor: (@x, @y) ->
    @position = new Vector x, y
    @velocity = new Vector 0, 0
    @radius = 15

  update: ->
    @velocity.add @acceleration
    @velocity.limit MAX_SPEED
    @position.add @velocity

  checkBounds: (area) ->
    @position.x = 0          if @position.x > area.width
    @position.x = area.width if @position.x < 0

    @position.y = 0           if @position.y > area.height
    @position.y = area.height if @position.y < 0

  draw: (context) ->
    # Draws the ball on the screen
    context.fillStyle = "#fff"
    context.beginPath()
    context.fillCircle @position.x, @position.y, @radius
    context.closePath()

class RandomAcceleratedBall extends Ball
  update: ->
    @acceleration = new Vector random(-1, 1), random(-1, 1)
    @acceleration.normalize()
    @acceleration.div(random(1, 2))
    super

class RandomDirectedBall extends Ball
  update: ->
    @acceleration = new Vector random(-1, 1), random(-1, 1)
    @acceleration.normalize()
    @acceleration.div(2)
    super

class Example
  constructor: (container, width = 200, height = 200) ->
    @canvas  = $("<canvas width='#{width}' height='#{height}'></canvas>").appendTo($(container))[0]
    @context = @canvas.getContext("2d")

  start: -> do @loop

  loop: =>
    requestAnimationFrame @loop

    do @clearScreen

    @ball.update()
    @ball.checkBounds(@canvas)
    @ball.draw(@context)

  clearScreen: ->
    @context.fillStyle = "rgba(14, 14, 14, 0.2)"
    @context.fillRect 0, 0, @canvas.width, @canvas.height

class RandomAcceleration extends Example
  constructor: ->
    super
    @ball = new RandomAcceleratedBall(10, 10)

class RandomDirection extends Example
  constructor: ->
    super
    @ball = new RandomDirectedBall(10, 10)

window.RandomAcceleration = RandomAcceleration
window.RandomDirection = RandomDirection
