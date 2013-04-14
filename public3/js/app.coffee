# $ coffee -cb main.coffee
"use strict"

getPlotmode = ->
    v = $("select").val()  
    ans = PLOT_INSIDE_OUTSIDE  if v is "bt-color-inout"
    ans = PLOT_NUM_ITERATIONS  if v is "bt-color-num" 
    ans = PLOT_FRAC_ITERATIONS if v is "bt-color-frac-num"
    ans = PLOT_FRAC            if v is "bt-color-frac"
    ans

$ ->
  start()

  $("#bt-reset").click -> start()
  $("select").change ->
    resetMandel getPlotmode()

  $("#bt-zoomin").click  ->
    zoom = MAX_RANGE / ((range[0][1] - range[0][0]))
    zoomMandel(null, zoom * 2.0)
  $("#bt-zoomout").click  ->
    zoom = MAX_RANGE / ((range[0][1] - range[0][0]))
    zoomMandel(null, zoom * 0.5)
  $("#st-zoom").change  ->
    zoom_old = MAX_RANGE / ((range[0][1] - range[0][0]))
    zoom = parseInt($("#st-zoom").val(), 10)
    if (not isNaN(zoom)) and (zoom > 0)
      zoomMandel(null, zoom)
    else
      $("#st-zoom").val(zoom_old)

N = 512
ESC_RADIUS = 20
LOG2 = Math.log(2)
MAX_RANGE = 4
MIN_RANGE = 0.0000000000000001 # 0.00000095367431640625

PLOT_INSIDE_OUTSIDE = 0
PLOT_NUM_ITERATIONS = 1
PLOT_FRAC_ITERATIONS = 2
PLOT_FRAC = 3

range = null
step_timer = null
step_count = null
start_time = null
isAPointOutside = false

# 描画方法 0
genColor_InOut = (cpe) ->
  [255, 255, 255]

# 描画方法 1
genColor_Count = (cpe) ->
  l = Math.floor(255 - 255 / cpe.it)    
  [l, l, 255]

# 描画方法 2
genColor_CountZ = (cpe) ->
  zmod = Math.sqrt(cpe.z[0] * cpe.z[0] + cpe.z[1] * cpe.z[1])
  iterFra = cpe.it + 1 - Math.log(Math.log(zmod)) / LOG2
  l = Math.floor(255 - 255 / iterFra)
  # [l, l, l]
  [l, l, 255]
        
# 描画方法 3
genColor_Z = (cpe) ->
  zmod = Math.sqrt(cpe.z[0] * cpe.z[0] + cpe.z[1] * cpe.z[1])
  r = zmod % 256
  g = cpe.it % 256
  [r, g, 255]

genColorList = [genColor_InOut, genColor_Count, genColor_CountZ, genColor_Z]

# 中心位置と表示幅を指定して、表示領域を決める
moveRange = (p, r) ->
  r = MAX_RANGE if r > MAX_RANGE
  r = MIN_RANGE if r < MIN_RANGE
  r2 = r / 2
  range[0] = [p[0] - r2, p[0] + r2]
  range[1] = [p[1] - r2, p[1] + r2]

  if range[0][0] < -MAX_RANGE / 2
    range[0][0] = -MAX_RANGE / 2
    range[0][1] = r - MAX_RANGE / 2
  else if range[0][1] > MAX_RANGE / 2
    range[0][0] = MAX_RANGE / 2 - r
    range[0][1] = MAX_RANGE / 2
  if range[1][0] < -MAX_RANGE / 2
    range[1][0] = -MAX_RANGE / 2
    range[1][1] = r - MAX_RANGE / 2
  else if range[1][1] > MAX_RANGE / 2
    range[1][0] = MAX_RANGE / 2 - r
    range[1][1] = MAX_RANGE / 2

# 初期設定で表示する。
start = ->
  canvas = document.getElementById("main_canvas")
  canvas.width = canvas.height = N
  canvas.onmousedown = canvasOnMouseDown
  canvas.oncontextmenu = -> false

  ctx = canvas.getContext("2d")
  ctx.fillStyle = "#fff"
  ctx.fillRect 0, 0, N, N

  frags = window.location.href.split("#")
  args = []
  zoom = 2
  range = [[-MAX_RANGE/2, MAX_RANGE/2], [-MAX_RANGE/2, MAX_RANGE/2]]
  plotMode = PLOT_INSIDE_OUTSIDE

  args = frags[1].split(",")  if frags.length > 1
  plotMode = parseInt(args[0], 10)  if args.length >= 1
  range = [[parseFloat(args[1]), parseFloat(args[2])], [parseFloat(args[3]), parseFloat(args[4])]]  if args.length >= 5
  zoom = parseInt(args[5], 10)  if args.length >= 6

  resetMandel plotMode, range

# マウスクリック位置を中心にして、拡大縮小表示する。(左クリック：拡大, 右クリック: 縮小)
canvasOnMouseDown = (e) ->
  e = e or window.event
  canvas = document.getElementById("main_canvas")
  pxPnt = [e.clientX - canvas.offsetLeft, e.clientY - canvas.offsetTop]
  r = range[0][1] - range[0][0]
  pnt = [(pxPnt[0] / N) * r + range[0][0], (pxPnt[1] / N) * r + range[1][0]]

  zoomFactor = (if (e.which is 1) then 2.0 else 0.5) # leftButton: zoomIn, leftButton: zoomOut
  zoom =  MAX_RANGE / r
  zoomMandel pnt, zoom * zoomFactor

# 中心位置と倍率を指定して表示しなおす。
zoomMandel = (pnt, factor) ->
  pnt = [ (range[0][0] + range[0][1])/2, (range[1][0] + range[1][1])/2]  if pnt == null

  r = range[0][1] - range[0][0]
  moveRange pnt, MAX_RANGE / factor
  resetMandel getPlotmode()

# 色モードと領域を指定して表示しなおす。
resetMandel = (plotMode, newRange) ->
  step_count = 0
  newRange = range if not newRange or isNaN(newRange[0][0]) or isNaN(newRange[0][1]) or isNaN(newRange[1][0]) or isNaN(newRange[1][1])

  range = newRange
  zoom = Math.round(MAX_RANGE / ((range[0][1] - range[0][0])))
  $("#st-zoom").val(zoom)
  $("#per-link").attr("href", "\##{plotMode},#{range[0][0]},#{range[0][1]},#{range[1][0]},#{range[1][1]},#{zoom}")
  mandelPlane = ( ->
    ret = []
    PIXS = N
    dx = (range[0][1] - range[0][0]) / PIXS
    dy = (range[1][1] - range[1][0]) / PIXS
    c = [range[0][0], range[1][0]]

    j = 0
    while j < PIXS
      c[0] = range[0][0]

      i = 0
      while i < PIXS
        ret[i + j * PIXS] =
          c: [c[0], c[1]]
          z: [0, 0]
          it: 0

        c[0] += dx
        i++
      c[1] += dy
      j++
    ret
  )()
  canvas = document.getElementById("main_canvas")
  ctx = canvas.getContext("2d")
  isAPointOutside = false  
  clearInterval(step_timer) if step_timer != null
  step_timer = setInterval step, 50, plotMode, mandelPlane, ctx

  start_time = new Date().getTime()
  $("#status").show()

step = (plotMode, mandelPlane, ctx) ->

  # １ステップ計算を勧めて一面を表示更新する。
  walkCanvas = ->
    # fnc = (z, c) -> [z[0] * z[0] - z[1] * z[1] + c[0], 2 * z[0] * z[1] + c[1]]
    # abs = (z) -> Math.sqrt z[0] * z[0] + z[1] * z[1]
    colorF = genColorList[plotMode]

    ret_changed = false
    ret_isapoint = false

    imd = ctx.getImageData(0, 0, N, N)
    cpa = imd.data
    esc_radius = ESC_RADIUS

    idx1 = 0
    for i in [0 ... N * N]
      cpe = mandelPlane[i]
      if cpe.out
        idx1 += 4
        continue
  
      # cpe.z = fnc(cpe.z, cpe.c)
      cpe.z = [cpe.z[0] * cpe.z[0] - cpe.z[1] * cpe.z[1] + cpe.c[0], 2 * cpe.z[0] * cpe.z[1] + cpe.c[1]]
      cpe.it++
      # abs_v = abs(cpe.z)
      abs_v = Math.sqrt cpe.z[0] * cpe.z[0] + cpe.z[1] * cpe.z[1]
      if (abs_v > esc_radius)
        ret_isapoint = true
        cpe.out = true

      color = if cpe.out then colorF(cpe) else [0, 0, 0]
      ret_changed = true if (ret_changed is false) and (cpa[idx1] isnt color[0])
      cpa[idx1++] = color[0]
      cpa[idx1++] = color[1]
      cpa[idx1++] = color[2]
      cpa[idx1++] = 255
  
    ctx.putImageData imd, 0, 0
    {changed: ret_changed, isapoint: ret_isapoint}

  ret = walkCanvas()
  colorChange = ret.changed
  isAPointOutside = isAPointOutside || ret.isapoint

  $("#st-step").text(++step_count)
  $("#time").text((new Date().getTime() - start_time)/1000.0)
  
  # 画素の色変化かなくなったら、 step を進めるのを中止する。
  if (colorChange is false) and (isAPointOutside is true)
    clearInterval(step_timer) if step_timer != null
    step_timer = null
    $("#status").hide()
