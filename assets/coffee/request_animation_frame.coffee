do ->
  time = 0

  for vendor in ["ms", "moz", "webkit", "o"] when not window.requestAnimationFrame
    window.requestAnimationFrame = window[ vendor + "RequestAnimationFrame"]
    window.cancelRequestAnimationFrame = window[ vendor + "CancelRequestAnimationFrame"]

  if not window.requestAnimationFrame
    window.requestAnimationFrame = (callback, element) ->
      now = new Date().getTime()
      delta = Math.max 0, 16 - (now - old)
      setTimeout (-> callback(time + delta)), delta
      old = now + delta

  if not window.cancelAnimationFrame
    window.cancelAnimationFrame = (id) -> clearTimeout id
