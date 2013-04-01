
iCanvasWidth = null
iCanvasHeight = null
ctx = null
mandelPixels = null

iCanvasX = null
iCanvasY = null
currX = null
currY = null
newY = null

mouseDown  = null
mbX = null
mbY = null

backImage = null

MAX_CONTROL_COLORS = 5
MAX_COLORS = 512
ITERATION_LIMIT = 100
loop_max = 2560
controlColors = new Array(MAX_CONTROL_COLORS)
colors = new Array(MAX_COLORS)
pmin = -2.25
pmax = 0.75
qmin = -1.5
qmax = 1.5

lastColor = 0

textOut = (s, x, y) ->
  ctx.textBaseline = "top"
  ctx.font = "10px 'Tahoma, Verdana, Arial, Helvetica'"
  ctx.lineWidth = 2
  ctx.strokeStyle = "#001"
  ctx.strokeText s, x, y
  ctx.fillStyle = "#eeb"
  ctx.fillText s, x, y

report_Timing = (msg) ->
  if (false)
    textOut msg, 4, 4
    textOut "x: #{pmin} .. #{pmax}", 4, 16
    textOut "y: #{qmin} .. #{qmax}", 4, 28
    textOut "zoom: #{zoomStr(pmin, pmax)}", 4, 40
  else
    $("#info_time").text("#{msg}")

show_scale = ->
  str = (3.0 /(pmax - pmin)).toFixed(2)
  $("#info_scale").val(str)

set_scale = (v) ->
  return false if isNaN(v)
  return false if v > MAX_SCALE

  p0 = (pmin + pmax) /2.0
  q0 = (qmin + qmax) /2.0

  pw_half = 3.0 / (2.0 * v)
  qw_half = 3.0 / (2.0 * v)

  pmin0 = p0 - pw_half
  pmax0 = p0 + pw_half
  qmin0 = q0 - qw_half
  qmax0 = q0 + qw_half

  return false if (3.0 / (pmax0 - pmin0) > MAX_SCALE)
  pmin = pmin0
  pmax = pmax0
  qmin = qmin0
  qmax = qmax0
   
  show_scale()
    
show_loop_max = ->
  $("#info_loop_max").val(loop_max)

set_loop_max = (v) ->
  # console.log "#-- set loop_max: #{loop_max}"
  loop_max = v
  show_loop_max()

show_mousepos = (x, y) ->
  xinfoStr = "x: #{pmin} .. #{pmax} x0: #{(pmax + pmin)/2.0}"
  yinfoStr = "y: #{qmin} .. #{qmax} y0: #{(qmax + qmin)/2.0}"
  $("#info_x").text(xinfoStr)
  $("#info_y").text(yinfoStr)
  $("#info_mousepos_x").val(x)
  $("#info_mousepos_y").val(y)

set_mousepos_x = (x) ->
  set_mousepos(x, (qmin + qmax) /2.0)

set_mousepos_y = (y) ->
  set_mousepos((pmin + pmax) / 2.0, y)
  
set_mousepos = (x, y) ->
  x = parseFloat(x)
  y = parseFloat(y)
  p0 = (pmin + pmax) /2.0
  q0 = (qmin + qmax) /2.0
  dx = x - p0
  dy = y - q0
  pmin = pmin + dx 
  pmax = pmax + dx
  qmin = qmin + dy
  qmax = qmax + dy

###
 * Draw a Pixel on the canvas context. This method is caching the last color used
 * as the ctx.fillStyle is an expensive method.
 * 
 * @param x
 * @param y
 * @param c
###
drawPixel = (x, y, c) ->
  iOffset = 4 * (y * iCanvasWidth + x)
  mandelPixels[iOffset    ] = colors[c][0] # r
  mandelPixels[iOffset + 1] = colors[c][1] # g
  mandelPixels[iOffset + 2] = colors[c][2] # b
  mandelPixels[iOffset + 3] = 255          # alpah

###
 * 
###
resetMandel = (w, h) ->
  scale = 3.0 / h
  pmin = -(9.0 / 12.0) * w * scale
  pmax = (3.0 / 12.0) * w * scale
  qmin = -1.5
  qmax = 1.5

  show_mousepos((pmin + pmax) / 2.0 , (qmin + qmax) / 2.0)
  show_loop_max()
  show_scale()

#
MAX_SCALE = 1.0e14

zoomMandel = (scale) ->
  pw = (pmax - pmin) / scale
  qw = (qmax - qmin) / scale
  return false if (scale > 1) and (3.0/pw > MAX_SCALE or 3.0/qw > MAX_SCALE)

  pc = (pmax + pmin) / 2.0 
  pmin = pc - pw / 2.0
  pmax = pc + pw / 2.0

  qc = (qmax + qmin) / 2.0 
  qmin = qc - qw / 2.0
  qmax = qc + qw / 2.0
  return true

###
 * 
###
resetControlColors = ->
  controlColors[0] = [0x00, 0x00, 0x20]
  controlColors[1] = [0xff, 0xff, 0xff]
  controlColors[2] = [0x00, 0x00, 0xa0]
  controlColors[3] = [0x40, 0xff, 0xff]
  controlColors[4] = [0x20, 0x20, 0xff]

###
 * 
###
computeColors = ->
  colors[0] = [0, 0, 0]
  i = 0
  while i < MAX_CONTROL_COLORS - 1
    rstep = (controlColors[i + 1][0] - controlColors[i][0]) / 63
    gstep = (controlColors[i + 1][1] - controlColors[i][1]) / 63
    bstep = (controlColors[i + 1][2] - controlColors[i][2]) / 63

    k = 0
    while k < 64
      colors[k + (i * 64) + 1] = [
        Math.round(controlColors[i][0] + rstep * k),
        Math.round(controlColors[i][1] + gstep * k),
        Math.round(controlColors[i][2] + bstep * k)
      ]
      k++
    i++

  i = 257
  while i < MAX_COLORS
    colors[i] = colors[i - 256]
    i++

computeMandel = ->
  KMAX = 256
  loop_max

  xstep = (pmax - pmin) / iCanvasWidth
  ystep = (qmax - qmin) / iCanvasHeight
  
  # declare and initialise variables, for speed
  x = 0.0
  y = 0.0
  r = 1.0
  
  # create a back image and get a pointer to the pixels array
  mandelImage = ctx.getImageData(0, 0, iCanvasWidth, iCanvasHeight)
  mandelPixels = mandelImage.data
  start = new Date().getTime()
  sy = 0

  report_Timing "caluclationg ..."

  while sy < iCanvasHeight
    sx = 0

    while sx < iCanvasWidth
      p = pmin + xstep * sx
      q = qmax - ystep * sy
      k = 0
      x0 = 0.0
      y0 = 0.0
      loop
        x = x0 * x0 - y0 * y0 + p
        y = 2 * x0 * y0 + q
        x0 = x
        y0 = y
        r = x * x + y * y
        k++
        break unless (r <= ITERATION_LIMIT) and (k < loop_max)
      # k = 0  if k >= KMAX
      k = k % KMAX

      # draw the pixel
      drawPixel sx, sy, k
      sx++
    sy++
  ctx.putImageData mandelImage, 0, 0
  elapsed = new Date().getTime() - start
  report_Timing "#{elapsed} ms,"
  show_scale()
  
onMouseDown = (e) ->
  e = window.event or e
  mouseDown = true
  mbX = e.offsetX or (e.clientX - iCanvasX)
  mbY = e.offsetY or (e.clientY - iCanvasY)
  backImage = ctx.getImageData(0, 0, iCanvasWidth, iCanvasHeight)

onMouseMove = (e) ->
  e = window.event or e

  currX = e.offsetX or (e.clientX - iCanvasX)
  currY = e.offsetY or (e.clientY - iCanvasY)
  if mouseDown
    newY = mbY + (booleanToInt(currY > mbY) * 2 - 1) * Math.round(iCanvasHeight * Math.abs(currX - mbX) / iCanvasWidth)
    ctx.putImageData backImage, 0, 0
    ctx.strokeStyle = "rgb(170,255,65)"
    ctx.strokeRect mbX, mbY, currX - mbX, newY - mbY

  x0 = pmin + currX * (pmax - pmin) / iCanvasWidth
  y0 = qmax - currY * (qmax - qmin) / iCanvasHeight
  show_mousepos(x0, y0)

onMouseUp = (e) ->
  e = window.event or e
  if mouseDown
    currX = e.offsetX or (e.clientX - iCanvasX)
    currY = e.offsetY or (e.clientY - iCanvasY)
    newX = currX
    newY = mbY + (booleanToInt(currY > mbY) * 2 - 1) * Math.round(iCanvasHeight * Math.abs(currX - mbX) / iCanvasWidth)
    if newX < mbX
      hx = newX
      newX = mbX
      mbX = hx
    if newY < mbY
      hy = newY
      newY = mbY
      mbY = hy
    console.log mbX + ", " + mbY + " to " + newX + ", " + newY
    
    # only bother if the size of the square is more than 3x3 pixels
    if (Math.abs(newX - mbX) > 3) and (Math.abs(newY - mbY) > 3)
      pw = pmax - pmin
      qw = qmax - qmin
      if (3.0 / pw < MAX_SCALE and 3.0 / qw < MAX_SCALE)
        pmin = pmin + mbX * pw / iCanvasWidth
        pmax = pmax - (iCanvasWidth - newX) * pw / iCanvasWidth
        qmin = qmin + (iCanvasHeight - newY) * qw / iCanvasHeight
        qmax = qmax - mbY * qw / iCanvasHeight
        computeMandel()
    else
      p0 = pmin + newX * (pmax - pmin) / iCanvasWidth
      q0 = qmax - newY * (qmax - qmin) / iCanvasHeight
      pDiff = (pmin + pmax) / 2.0 - p0
      qDiff = (qmin + qmax) / 2.0 - q0
      pmin -= pDiff
      pmax -= pDiff
      qmin -= qDiff
      qmax -= qDiff
      computeMandel()

  mouseDown = false

onTouchStart = (e) ->
  e.preventDefault()
  touch = e.targetTouches[0]
  mouseDown = true
  mbX = touch.pageX - iCanvasX
  mbY = touch.pageY - iCanvasY
  backImage = ctx.getImageData(0, 0, iCanvasWidth, iCanvasHeight)

onTouchMove = (e) ->
  e.preventDefault()
  touch = e.targetTouches[0]
  if mouseDown
    tcurrX = touch.pageX - iCanvasX
    tcurrY = touch.pageY - iCanvasY
    newY = mbY + (booleanToInt(tcurrY > mbY) * 2 - 1) * Math.round(iCanvasHeight * Math.abs(tcurrX - mbX) / iCanvasWidth)
    ctx.putImageData backImage, 0, 0
    ctx.strokeStyle = "rgb(170,255,65)"
    ctx.strokeRect mbX, mbY, tcurrX - mbX, newY - mbY
    tcurrY = newY

  p0 = pmin + tcurrX * (pmax - pmin) / iCanvasWidth
  q0 = qmax - tcurrY * (qmax - qmin) / iCanvasHeight
  show_mousepos(p0, q0)

onTouchEnd = (e) ->
  touch = e.targetTouches[0]
  if mouseDown
    newX = tcurrX
    newY = tcurrY
    if newX < mbX
      hx = newX
      newX = mbX
      mbX = hx
    if newY < mbY
      hy = newY
      newY = mbY
      mbY = hy
    
    # only bother if the size of the square is more than 3x3 pixels
    if (Math.abs(newX - mbX) > 3) and (Math.abs(newY - mbY) > 3)
      pw = pmax - pmin
      qw = qmax - qmin
      if (3.0/pw < MAX_SCALE and 3.0/qw < MAX_SCALE)
        pmin = pmin + mbX * pw / iCanvasWidth
        pmax = pmax - (iCanvasWidth - newX) * pw / iCanvasWidth
        qmin = qmin + (iCanvasHeight - newY) * qw / iCanvasHeight
        qmax = qmax - mbY * qw / iCanvasHeight

      computeMandel()

  mouseDown = false

wheel = (event) ->
  delta = 0  
  event = window.event or event

  if (event.wheelDelta)  
    delta = event.wheelDelta / 120
  else if (event.detail)
    delta = -event.detail / 3
  
  wheelhandle(delta) if (delta != 0)

  event.preventDefault() if (event.preventDefault)
  event.returnValue = false

wheelhandle = (delta) ->
  scale = if (delta < 0) then 0.8 else 1.2
  computeMandel() if zoomMandel(scale)

###
 * Converts the canvas to a PNG and modifies the document location to it
 * 
 * @param canvasElement
###
convertToPng = (canvasElement, outputElement) ->
  canvas = document.getElementById(canvasElement)
  
  # See http://www.html5.jp/canvas/ref/HTMLCanvasElement/toDataURL.html
  url = canvas.toDataURL()
  newwindow = window.open(url, "PNG image of canvas")

###
 * @param canvasElement
 * @param w
 * @param h
###
initMandel = (canvasElement, w, h) ->
  iCanvasWidth = w
  iCanvasHeight = h
  canvas = document.getElementById(canvasElement)
  ctx = canvas.getContext("2d")
  canvas.width = w
  canvas.height = h
  
  # get the location of the canvas on the page
  iCanvasX = canvas.offsetLeft
  iCanvasY = canvas.offsetTop
  resetMandel w, h
  resetControlColors()
  computeColors()
  canvas.onmousedown = onMouseDown
  canvas.onmousemove = onMouseMove
  canvas.onmouseup = onMouseUp

  if (canvas.addEventListener)
    canvas.addEventListener('DOMMouseScroll', wheel, false)

  canvas.onmousewheel = wheel

  canvas.addEventListener "touchstart", onTouchStart
  canvas.addEventListener "touchmove", onTouchMove
  canvas.addEventListener "touchend", onTouchEnd

  console.log "+ canvas initialised at " + iCanvasX + " " + iCanvasY
