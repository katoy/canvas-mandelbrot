
"use strict"

# e.data = {
#   image:       @worker_data
#   id:          @pool[i].id
#   worker_size: @worker_size
#   width:       @width
#   height:      @height
#   x_center:    @x_center
#   y_center:    @y_center
#   iterations:  @iterations
#   escape:      @escape
#   view_range:  @view_range
#

self.addEventListener "message", ((e) ->
  x_step = e.data.view_range / e.data.width
  y_step = e.data.view_range / e.data.height
  y_start = e.data.height / e.data.worker_size * e.data.id
  y_end = e.data.height / e.data.worker_size
  data = new Int32Array(e.data.image.data.buffer)
  colorFunc = if e.data.plotMode is "color32" then getColor32 else getColorGray
  escape = e.data.escape
  iterations = e.data.iterations
  
  for y in [0 ... y_end]
    iy = e.data.y_center - e.data.view_range / 2 + (y + y_start) * y_step
    for x in [0 ... e.data.width]
      rx = e.data.x_center - e.data.view_range / 2 + x * x_step
      zx = rx
      zy = iy
      zx2 = 0
      zy2 = 0

      i = 0
      while zx2 + zy2 < escape and i < iterations
        zx2 = zx * zx
        zy2 = zy * zy
        zy = (zx + zx) * zy + iy
        zx = zx2 - zy2 + rx
        ++i

      data[y * e.data.width + x] = colorFunc(i)

  self.postMessage e.data.image
), false

getColorGray = (ite) ->
  ite = ite % 256
  (255 << 24) | (ite << 16) | (ite << 8) | ite

getColor32 = (ite) ->
  base = 32
  d = (ite % base) * 256 / base
  m = (d / 42.667) << 0
  rgb = switch m
    #blue -> cyan
    when 0
      [0, 6 * d, 255]
    #cyan -> green
    when 1
      [0, 255, 255 - 6 * (d - 43)]
    #green -> yellow
    when 2
      [6 * (d - 86), 255, 0]
    #yellow -> red
    when 3
      [255, 255 - 6 * (d - 129), 0]
    #red -> magenta
    when 4
      [255, 0, 6 * (d - 171)]
    #magenta -> blue
    when 5
      [255 - 6 * (d - 214), 0, 255]
    else
      [6, 6, 6]

  (255 << 24) | rgb[0] << 16 | rgb[1] << 8 | rgb[2]

