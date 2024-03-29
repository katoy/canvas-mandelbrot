
resetPresetStyles = ->
  document.getElementById("preset_" + i).className = ""  for i in [0 .. 7]

load = (element, w, h) ->  
  # initLogger();
  if element
    resetPresetStyles()
    element.className = "selected"
  initMandel "canvas", w, h
  computeMandel()

$ ->

  $('#zoomIn').click ->
    computeMandel() if zoomMandel(2.0)

  $('#zoomOut').click ->
    computeMandel() if zoomMandel(0.5)

  $('#reset').click ->
    resetMandel(iCanvasWidth, iCanvasHeight)
    computeMandel()

  $('#info_loop_max').change ->
    set_loop_max(parseInt($(this).val()))
    computeMandel()

  $('#info_mousepos_x').change ->
    set_mousepos_x(parseFloat($(this).val()))
    computeMandel()

  $('#info_mousepos_y').change ->
    set_mousepos_y(parseFloat($(this).val()))
    computeMandel()

  $('#info_scale').change ->
    set_scale(parseFloat($(this).val()))
    computeMandel()
