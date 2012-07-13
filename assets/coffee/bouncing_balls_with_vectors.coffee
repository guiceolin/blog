class Ball
  constructor: (@x, @y) ->
    @position = new Vector x, y
    @velocity = new Vector 3, 1.5
    @radius = 10

  update: ->
    # Incrementing the ball position by adding the velocity vector to the position vector
    @position.add(@velocity)

  # Rebounds the ball when it hits any of the bounds of the canvas
  checkBounds: (area) ->
    # Inverting the x velocity when the ball touches the left or right side of the screen
    @velocity.x *= -1 if @position.x > area.width  or @position.x < 0

    # Inverting the y velocity when the ball touches the up or down side of the screen
    @velocity.y *= -1 if @position.y > area.height or @position.y < 0

  draw: (context) ->
    # Draws the ball on the screen
    context.fillStyle = "#fff"
    context.beginPath()
    # As the canvas API doesn't support passing vectors as arguments, so we must inform the x and y scalars
    context.fillCircle @position.x, @position.y, @radius
    context.closePath()

class Example
  constructor: (width = 200, height = 200) ->
    @canvas  = $("<canvas width='#{width}' height='#{height}'></canvas>").appendTo($("#first_example"))[0]
    @context = @canvas.getContext("2d")

    @ball = new Ball(10, 10)

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

window.BallWithVectors = Example
