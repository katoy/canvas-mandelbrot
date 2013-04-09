"use strict"

workers = null
workerCount = null
jobNum = 0
running = false
repaintTimeout = null
xmin = null
ymin = null
xmax = null
ymax = null
dx = null
dy = null
jobs = null
jobsCompleted = null
OSC = null
OSG = null
canvas = null
graphics = null
dragbox = null
maxIterations = null
stretchPalette = true
fixedPaletteLength = 250
paletteLength = null
palette = null
job = null

newWorkers = (count) ->
  i = 0
  if workers
    i = 0
    while i < workerCount
      workers[i].terminate()
      i++
  workers = []
  workerCount = count
  i = 0
  while i < workerCount
    workers[i] = new Worker("MandelbrotWorker.js")
    workers[i].onmessage = jobFinished
    i++

setLimits = (x1, x2, y1, y2) ->
  xmin = x1
  xmax = x2
  ymin = y1
  ymax = y2
  if xmax < xmin
    temp = xmin
    xmin = xmax
    xmax = temp
  if ymax < ymin
    temp = ymax
    ymax = ymin
    ymin = temp
  width = xmax - xmin
  height = ymax - ymin
  aspect = width / height
  windowAspect = canvas.width / canvas.height
  if aspect < windowAspect
    newWidth = width * windowAspect / aspect
    center = (xmax + xmin) / 2
    xmax = center + newWidth / 2
    xmin = center - newWidth / 2
  else if aspect > windowAspect
    newHeight = height * aspect / windowAspect
    center = (ymax + ymin) / 2
    ymax = center + newHeight / 2
    ymin = center - newHeight / 2
  dx = (xmax - xmin) / (canvas.width - 1)
  dy = (ymax - ymin) / (canvas.height - 1)

doDraw = ->
  graphics.drawImage OSC, 0, 0
  dragbox.draw()  if dragbox and dragbox.width > 2 and dragbox.height > 2

repaint = ->
  doDraw()
  if running
    repaintTimeout = setTimeout(repaint, 500)
    $("#message").html "Computing...  Completed " + jobsCompleted + " of " + canvas.height + " rows"
  else
    $("#message").html "Idle"

stopJob = ->
  if running
    jobNum++
    running = false
    clearTimeout repaintTimeout  if repaintTimeout
    repaintTimeout = null
    repaint()

startJob = ->
  stopJob()  if running
  graphics.fillRect 0, 0, canvas.width, canvas.height
  OSG.fillStyle = "#BBB"
  OSG.fillRect 0, 0, canvas.width, canvas.height
  jobs = []
  y = ymax
  rows = canvas.height
  columns = canvas.width
  row = 0

  while row < rows
    jobs[rows - 1 - row] =
      jobNum: jobNum
      row: row
      maxIterations: maxIterations
      y: y
      xmin: xmin
      columns: columns
      dx: dx

    y -= dy
    row++
  jobsCompleted = 0
  i = 0

  while i < workerCount
    j = jobs.pop()
    j.workerNum = i
    workers[i].postMessage j
    i++
  running = true
  $("#message").html "Computing..."
  repaintTimeout = setTimeout(repaint, 333)

jobFinished = (msg) ->
  job = msg.data
  return  unless job.jobNum is jobNum
  iterationCounts = job.iterationCounts
  row = job.row
  columns = canvas.width
  col = 0

  while col < columns
    ct = iterationCounts[col]
    paletteIndex = 0
    if ct < 0
      OSG.fillStyle = "#000"
    else
      paletteIndex = iterationCounts[col] % paletteLength
      OSG.fillStyle = palette[paletteIndex]
    OSG.fillRect col, row, 1, 1
    col++
  jobsCompleted++
  if jobsCompleted is canvas.height
    stopJob()
  else if jobs.length > 0
    worker = workers[job.workerNum]
    j = jobs.pop()
    j.workerNum = job.workerNum
    worker.postMessage j

setDefaults = ->
  stopJob()
  setLimits -2.2, 0.8, -1.2, 1.2
  stretchPalette = true
  fixedPaletteLength = 250
  maxIterations = 100
  createPalette()
  $("#stretchPaletteCheckbox").attr "checked", true
  $("#paletteLengthPar").css "display", "none"
  $("#maxIterSelect").val 100
  $("#otherMaxIter").html "&nbsp;"
  $("#paletteLengthSelect").val "250"
  $("#otherPaletteLength").html "&nbsp;"
  startJob()

makeSpectralColor = (hue) ->
  section = Math.floor(hue * 6)
  fraction = hue * 6 - section
  r = 0
  g = 0
  b = 0
  switch section
    when 0
      r = 1
      g = fraction
      b = 0
    when 1
      r = 1 - fraction
      g = 1
      b = 0
    when 2
      r = 0
      g = 1
      b = fraction
    when 3
      r = 0
      g = 1 - fraction
      b = 1
    when 4
      r = fraction
      g = 0
      b = 1
    when 5
      r = 1
      g = 0
      b = 1 - fraction
  rx = new Number(Math.floor(r * 255)).toString(16)
  rx = "0" + rx  if rx.length is 1
  gx = new Number(Math.floor(g * 255)).toString(16)
  gx = "0" + gx  if gx.length is 1
  bx = new Number(Math.floor(b * 255)).toString(16)
  bx = "0" + bx  if bx.length is 1
  color = "#" + rx + gx + bx
  color

createPalette = ->
  length = (if stretchPalette then maxIterations else fixedPaletteLength)
  return  if length is paletteLength
  paletteLength = length
  palette = []
  i = 0

  while i < paletteLength
    hue = i / paletteLength
    palette[i] = makeSpectralColor(hue)
    i++

DragBox = (x, y) ->
  @x = @left = x
  @y = @top = y
  @width = 0
  @height = 0

setUpDragging = ->
  zoomin = 0
  dragbox = null # initially, the mouse is not being dragged.
  $("#mbcanvas").mousedown (e) ->
    return  if dragbox or e.button isnt 0
    offset = $("#mbcanvas").offset()
    x = Math.round(e.pageX - offset.left)
    y = Math.round(e.pageY - offset.top)
    dragbox = new DragBox(x, y)
    zoomin = not e.shiftKey
    doDraw()

  $("#mbcanvas").mousemove (e) ->
    if dragbox
      offset = $("#mbcanvas").offset()
      x = Math.round(e.pageX - offset.left)
      y = Math.round(e.pageY - offset.top)
      dragbox.setCorner x, y
      doDraw()

  $(document).mouseup ->
    
    # This is called when the mouse is released anywhere in the document.  This
    # is attached to the document, not the canvas, because the mouseup after a
    # mousedown on the canvas can occur anywhere.  (Actually, a saner langauge 
    # would send the mouseup to the same object that got the mousedown, but
    # javascript/jquery doesn't seem to do that.)
    if dragbox
      dragbox.zoom zoomin
      dragbox = null

changeWorkerCount = ->
  ct = parseInt($("#threadCountSelect").val())
  return  if ct is workerCount
  stopJob()
  newWorkers ct
  startJob()

changeMaxIterations = ->
  val = $("#maxIterSelect").val()
  iter = 0
  if val is "Other..."
    val = prompt("Enter the maximum number of iterations", maxIterations)
    iter = parseInt(val)
    if isNaN(iter) or iter < 1 or iter > 100000
      alert "Sorry, the value must be a positive integer, and not more than 100000."
      $("#maxIterSelect").val maxIterations
      return
    $("#otherMaxIter").html "(" + iter + ")"
  else
    iter = parseInt(val)
    $("#otherMaxIter").html "&nbsp;"
  return  if iter is maxIterations
  maxIterations = iter
  createPalette()
  startJob()

changeStretchPalette = ->
  checked = $("#stretchPaletteCheckbox").attr("checked")
  return  if stretchPalette is checked
  stretchPalette = checked
  newPaletteLength = (if stretchPalette then maxIterations else fixedPaletteLength)
  $("#paletteLengthPar").css "display", (if stretchPalette then "none" else "block")
  unless newPaletteLength is paletteLength
    createPalette()
    startJob()

changePaletteLength = ->
  val = $("#paletteLengthSelect").val()
  len = 0
  if val is "Other..."
    val = prompt("Enter the palette length.", fixedPaletteLength)
    len = parseInt(val)
    if isNaN(len) or len < 2 or len > 100000
      alert "Sorry, the value must be an integer, between 2 and 100000"
      $("#paletteLengthSelect").val fixedPaletteLength
      return
    $("#otherPaletteLength").html "(" + len + ")"
  else
    len = parseInt(val)
    $("#otherPaletteLength").html "&nbsp;"
  return  if len is fixedPaletteLength
  fixedPaletteLength = len
  unless fixedPaletteLength is paletteLength
    createPalette()
    startJob()

DragBox::draw = ->
  graphics.strokeStyle = "#FFF"
  graphics.strokeRect @left - 1, @top - 1, @width + 1, @height + 1
  graphics.strokeRect @left + 1, @top + 1, @width - 3, @height - 3
  graphics.strokeStyle = "#000"
  graphics.strokeRect @left, @top, @width - 1, @height - 1

DragBox::setCorner = (x1, y1) ->
  if x1 <= @x
    @left = x1
    @width = @x - x1
  else
    @left = @x
    @width = x1 - @x
  if y1 <= @y
    @top = y1
    @height = @y - y1
  else
    @top = @y
    @height = y1 - @y

DragBox::zoom = (zoomin) ->
  return  if @width <= 2 or @height <= 2
  stopJob()
  x1 = 0
  x2 = 0
  y1 = 0
  y2 = 0
  cx = 0
  cy = 0
  newWidth = 0
  newHeight = 0
  x1 = xmin + @left / canvas.width * (xmax - xmin)
  x2 = xmin + (@left + @width) / canvas.width * (xmax - xmin)
  y1 = ymax - (@top + @height) / canvas.height * (ymax - ymin)
  y2 = ymax - @top / canvas.height * (ymax - ymin)
  cx = (x1 + x2) / 2
  cy = (y1 + y2) / 2
  if zoomin is false
    newXmin = xmin + (xmin - x1) / (x2 - x1) * (xmax - xmin)
    newXmax = xmin + (xmax - x1) / (x2 - x1) * (xmax - xmin)
    newYmin = ymin + (ymin - y1) / (y2 - y1) * (ymax - ymin)
    newYmax = ymin + (ymax - y1) / (y2 - y1) * (ymax - ymin)
    setLimits newXmin, newXmax, newYmin, newYmax
  else
    newWidth = x2 - x1
    newHeight = y2 - y1
    setLimits cx - newWidth / 2, cx + newWidth / 2, cy - newHeight / 2, cy + newHeight / 2
  startJob()

$ ->
  unless window.Worker
    $("#message").html "Sorry, your browser does not support worker threads.<br>" + "This page should work with recent versions of Firefox, Safari,<br>" + "Chrome, and Opera.  It will probably work in Internet Explorer 10."
    return
  canvas = document.getElementById("mbcanvas")
  if not canvas or not canvas.getContext
    $("#message").html "Sorry, your browser doesn't support the canvas element."
    return
  graphics = canvas.getContext("2d")
  OSC = document.createElement("canvas")
  OSC.width = canvas.width
  OSC.height = canvas.height
  OSG = OSC.getContext("2d")
  graphics.fillStyle = "#BBB"
  createPalette()
  newWorkers 4
  $("#restoreButton").click setDefaults
  $("#threadCountSelect").val "4"
  $("#threadCountSelect").change changeWorkerCount
  $("#maxIterSelect").val "100"
  $("#maxIterSelect").change changeMaxIterations
  $("#stretchPaletteCheckbox").attr "checked", true
  $("#stretchPaletteCheckbox").change changeStretchPalette
  $("#paletteLengthSelect").val fixedPaletteLength
  $("#paletteLengthSelect").change changePaletteLength
  setUpDragging()
  setDefaults()

