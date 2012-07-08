class Ball
  constructor: (@x, @y) ->
    # Setting some random velocities here
    @xSpeed = 8
    @ySpeed = 3

    # The size of the ball
    @radius = 10

  # Increment the ball position based on its current speed
  update: ->
    @x += @xSpeed
    @y += @ySpeed

  # Rebounds the ball when it hits any of the bounds of the canvas
  checkBounds: (area) ->
    # Inverting the x velocity when the ball touches the left or right side of the screen
    @xSpeed *= -1 if @x + @radius > area.width  or @x - @radius < 0

    # Inverting the y velocity when the ball touches the up or down side of the screen
    @ySpeed *= -1 if @y + @radius > area.height or @y - @radius < 0

  draw: (context) ->
    # Draws the ball on the screen
    context.fillStyle = "#fff"
    context.beginPath()
    context.fillCircle @x, @y, @radius
    context.closePath()

class FirstExample
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

window.FirstExample = FirstExample
