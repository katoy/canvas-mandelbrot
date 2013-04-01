var load, resetPresetStyles;

resetPresetStyles = function() {
  var i, _i, _results;

  _results = [];
  for (i = _i = 0; _i <= 7; i = ++_i) {
    _results.push(document.getElementById("preset_" + i).className = "");
  }
  return _results;
};

load = function(element, w, h) {
  if (element) {
    resetPresetStyles();
    element.className = "selected";
  }
  initMandel("canvas", w, h);
  return computeMandel();
};

$(function() {
  $('#zoomIn').click(function() {
    if (zoomMandel(2.0)) {
      return computeMandel();
    }
  });
  $('#zoomOut').click(function() {
    if (zoomMandel(0.5)) {
      return computeMandel();
    }
  });
  $('#reset').click(function() {
    resetMandel(iCanvasWidth, iCanvasHeight);
    return computeMandel();
  });
  $('#info_loop_max').change(function() {
    set_loop_max(parseInt($(this).val()));
    return computeMandel();
  });
  $('#info_mousepos_x').change(function() {
    set_mousepos_x(parseFloat($(this).val()));
    return computeMandel();
  });
  $('#info_mousepos_y').change(function() {
    set_mousepos_y(parseFloat($(this).val()));
    return computeMandel();
  });
  return $('#info_scale').change(function() {
    set_scale(parseFloat($(this).val()));
    return computeMandel();
  });
});
