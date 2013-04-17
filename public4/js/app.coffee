"use strict"

mandelbrot = null

$ ->
  $("#pause").show()
  $("#cont").hide()

  mandelbrot = new Mandelbrot()
  mandelbrot.init()      # let's go - create canvas, image data and workers
  mandelbrot.setPlotMode("gray")
  mandelbrot.setIterations(50)
  mandelbrot.setZoom(100)
  mandelbrot.setPause(false)
  # mandelbrot.animate()   # start animation loop

  $("#gray").click  ->
    mandelbrot.setPlotMode("gray")
    mandelbrot.iterate() if mandelbrot.getPause()

  $("#color32").click ->
    mandelbrot.setPlotMode("color32")
    mandelbrot.iterate() if mandelbrot.getPause()

  $("#iterations").change ->
    v = parseInt($(this).val(), 10)
    mandelbrot.setIterations(v)
    mandelbrot.iterate() if mandelbrot.getPause()

  $('#scale').change ->
    v = parseFloat($(this).val())
    mandelbrot.setZoom(v)
    mandelbrot.iterate() if mandelbrot.getPause()

  $("#x0").change ->
    mandelbrot.setCenter(parseFloat($(this).val()), null)
    mandelbrot.iterate() if mandelbrot.getPause()

  $("#y0").change ->
    mandelbrot.setCenter(null, parseFloat($(this).val()))
    mandelbrot.iterate() if mandelbrot.getPause()

  $("#pause").click ->
    $("#cont").show()
    $(this).hide()
    mandelbrot.setPause(true)
    $(".editable").removeAttr("disabled")

  $("#cont").click ->
    $("#pause").show()
    $(this).hide()
    mandelbrot.setPause(false)
    $(".editable").attr("disabled", "disabled")
  

canvasOnMouseDown = (e) ->
  e = e or window.event
  canvas = $("canvas")[0]
  mandelbrot.setCenterByMouse(e.clientX - canvas.offsetLeft, e.clientY - canvas.offsetTop)
  mandelbrot.iterate() if mandelbrot.getPause()

class Mandelbrot
  constructor: ->
    # set some values    
    @iterations = 120 # 250
    @worker_size = 10  # 600 の約数にする事。2, 5, 10, 

    @escape = 4
    @count = 0
    @received = 0
    @refresh = true
    @pause = false
    @requestId = null

  init: (
      @width = 600, @height = 600, @view_range = 10,
      @x_center = -1.407566731001088,
      @y_center = 2.741525895538953e-10) ->

    self = this

    $("#x0").val(@x_center)
    $("#y0").val(@y_center)
    $("#scale").val((@width / @view_range).toFixed(2))

    # create main canvas and append it to div
    container = $("#content")
    @canvas = document.createElement("canvas")
    @canvas.width = @width
    @canvas.height = @height
    @canvas.onmousedown = canvasOnMouseDown
    container.append @canvas

    # create imagedata
    @context = @canvas.getContext("2d")
    @image = @context.getImageData(0, 0, @width, @height)
    @data = new Int32Array(@image.data.buffer)
    
    # create imagedata for webworkers
    @worker_data = @context.getImageData(0, 0, @width, @height / @worker_size)
    
    # create webworkers drop them in array
    @pool = []
    i = 0
    while i < @worker_size
      @pool[i] = new Worker("js/worker.js")
      @pool[i].idle = true
      @pool[i].id = i

      @pool[i].onerror = (e) ->
        console.log e.message
        console.log e.filename
        console.log e.lineno
  
      # on webworker finished 
      @pool[i].onmessage = (e) ->
        self.context.putImageData e.data, 0, self.height / self.worker_size * e.target.id
        self.received++
      i++

  animate: ()->
    @requestId = requestAnimationFrame @animate.bind(this)
    
    # refresh at init, then refresh when all webworkers are done and reset
    if @received is @worker_size | @refresh
      @received = 0
      @refresh = false
      @count++
      @view_range *= 0.95
      $("#scale").val((@width / @view_range).toFixed(2))

      @iterate()

  iterate: ->
    $("#scale").val((@width / @view_range).toFixed(2))
    for i in [0 ... @pool.length]
      @pool[i].postMessage
        image: @worker_data
        id: @pool[i].id
        worker_size: @worker_size
        width: @width
        height: @height
        x_center: @x_center
        y_center: @y_center
        iterations: @iterations
        escape: @escape
        view_range: @view_range
        plotMode : @plotMode

  setPlotMode: (@plotMode = "gray") ->

  setIterations: (@iterations = 100) ->

  setZoom: (@zoom = 100) ->
    @view_range = @width / @zoom

  setPause: (@pause = true) ->
    if @pause
      cancelAnimationFrame(@requestId)
      @requestId = null
      @refresh = false
    else
      @refresh = true
      @animate()   # start animation loop

  getPause: -> @pause

  setCenter: (x, y) ->
    @x_center = x if x != null
    @y_center = y if y != null
    $("#x0").val(@x_center)
    $("#y0").val(@y_center)

  setCenterByMouse: (mx, my) ->
    @setCenter( @view_range * ((mx / @width) - 0.5)  + @x_center,
                @view_range * ((my / @height) - 0.5) + @y_center )
