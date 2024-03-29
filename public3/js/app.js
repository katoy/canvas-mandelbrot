// Generated by CoffeeScript 1.6.2
(function() {
  "use strict";
  var ESC_RADIUS, LOG2, MAX_RANGE, MIN_RANGE, N, PLOT_FRAC, PLOT_FRAC_ITERATIONS, PLOT_INSIDE_OUTSIDE, PLOT_NUM2_ITERATIONS, PLOT_NUM_ITERATIONS, canvasOnMouseDown, genColorList, genColor_Count, genColor_Count2, genColor_CountZ, genColor_InOut, genColor_Z, getPlotmode, isAPointOutside, moveRange, range, resetMandel, start, start_time, step, step_count, step_timer, zoomMandel;

  getPlotmode = function() {
    var ans, v;

    v = $("select").val();
    if (v === "bt-color-inout") {
      ans = PLOT_INSIDE_OUTSIDE;
    }
    if (v === "bt-color-num") {
      ans = PLOT_NUM_ITERATIONS;
    }
    if (v === "bt-color-num2") {
      ans = PLOT_NUM2_ITERATIONS;
    }
    if (v === "bt-color-frac-num") {
      ans = PLOT_FRAC_ITERATIONS;
    }
    if (v === "bt-color-frac") {
      ans = PLOT_FRAC;
    }
    return ans;
  };

  $(function() {
    start();
    $("#bt-reset").click(function() {
      return start();
    });
    $("select").change(function() {
      return resetMandel(getPlotmode());
    });
    $("#bt-zoomin").click(function() {
      var zoom;

      zoom = MAX_RANGE / (range[0][1] - range[0][0]);
      return zoomMandel(null, zoom * 2.0);
    });
    $("#bt-zoomout").click(function() {
      var zoom;

      zoom = MAX_RANGE / (range[0][1] - range[0][0]);
      return zoomMandel(null, zoom * 0.5);
    });
    return $("#st-zoom").change(function() {
      var zoom, zoom_old;

      zoom_old = MAX_RANGE / (range[0][1] - range[0][0]);
      zoom = parseInt($("#st-zoom").val(), 10);
      if ((!isNaN(zoom)) && (zoom > 0)) {
        return zoomMandel(null, zoom);
      } else {
        return $("#st-zoom").val(zoom_old);
      }
    });
  });

  N = 512;

  ESC_RADIUS = 20;

  LOG2 = Math.log(2);

  MAX_RANGE = 4;

  MIN_RANGE = 0.0000000000000001;

  PLOT_INSIDE_OUTSIDE = 0;

  PLOT_NUM_ITERATIONS = 1;

  PLOT_NUM2_ITERATIONS = 2;

  PLOT_FRAC_ITERATIONS = 3;

  PLOT_FRAC = 4;

  range = null;

  step_timer = null;

  step_count = null;

  start_time = null;

  isAPointOutside = false;

  genColor_InOut = function(cpe) {
    return [255, 255, 255];
  };

  genColor_Count = function(cpe) {
    var l;

    l = Math.floor(255 - 255 / cpe.it);
    return [l, l, 255];
  };

  genColor_Count2 = function(cpe) {
    var base, d, m, rgb;

    if (cpe.it < 0) {
      return [0, 0, 0];
    }
    base = 32;
    d = (cpe.it % base) * 256 / base;
    m = (d / 42.667) << 0;
    return rgb = (function() {
      switch (m) {
        case 0:
          return [0, 6 * d, 255];
        case 1:
          return [0, 255, 255 - 6 * (d - 43)];
        case 2:
          return [6 * (d - 86), 255, 0];
        case 3:
          return [255, 255 - 6 * (d - 129), 0];
        case 4:
          return [255, 0, 6 * (d - 171)];
        case 5:
          return [255 - 6 * (d - 214), 0, 255];
        default:
          return [6, 6, 6];
      }
    })();
  };

  genColor_CountZ = function(cpe) {
    var iterFra, l, zmod;

    zmod = Math.sqrt(cpe.z[0] * cpe.z[0] + cpe.z[1] * cpe.z[1]);
    iterFra = cpe.it + 1 - Math.log(Math.log(zmod)) / LOG2;
    l = Math.floor(255 - 255 / iterFra);
    return [l, l, 255];
  };

  genColor_Z = function(cpe) {
    var g, r, zmod;

    zmod = Math.sqrt(cpe.z[0] * cpe.z[0] + cpe.z[1] * cpe.z[1]);
    r = zmod % 256;
    g = cpe.it % 256;
    return [r, g, 255];
  };

  genColorList = [genColor_InOut, genColor_Count, genColor_Count2, genColor_CountZ, genColor_Z];

  moveRange = function(p, r) {
    var r2;

    if (r > MAX_RANGE) {
      r = MAX_RANGE;
    }
    if (r < MIN_RANGE) {
      r = MIN_RANGE;
    }
    r2 = r / 2;
    range[0] = [p[0] - r2, p[0] + r2];
    range[1] = [p[1] - r2, p[1] + r2];
    if (range[0][0] < -MAX_RANGE / 2) {
      range[0][0] = -MAX_RANGE / 2;
      range[0][1] = r - MAX_RANGE / 2;
    } else if (range[0][1] > MAX_RANGE / 2) {
      range[0][0] = MAX_RANGE / 2 - r;
      range[0][1] = MAX_RANGE / 2;
    }
    if (range[1][0] < -MAX_RANGE / 2) {
      range[1][0] = -MAX_RANGE / 2;
      return range[1][1] = r - MAX_RANGE / 2;
    } else if (range[1][1] > MAX_RANGE / 2) {
      range[1][0] = MAX_RANGE / 2 - r;
      return range[1][1] = MAX_RANGE / 2;
    }
  };

  start = function() {
    var args, canvas, ctx, frags, plotMode, zoom;

    canvas = document.getElementById("main_canvas");
    canvas.width = canvas.height = N;
    canvas.onmousedown = canvasOnMouseDown;
    canvas.oncontextmenu = function() {
      return false;
    };
    ctx = canvas.getContext("2d");
    ctx.fillStyle = "#fff";
    ctx.fillRect(0, 0, N, N);
    frags = window.location.href.split("#");
    args = [];
    zoom = 2;
    range = [[-MAX_RANGE / 2, MAX_RANGE / 2], [-MAX_RANGE / 2, MAX_RANGE / 2]];
    plotMode = PLOT_INSIDE_OUTSIDE;
    if (frags.length > 1) {
      args = frags[1].split(",");
    }
    if (args.length >= 1) {
      plotMode = parseInt(args[0], 10);
    }
    if (args.length >= 5) {
      range = [[parseFloat(args[1]), parseFloat(args[2])], [parseFloat(args[3]), parseFloat(args[4])]];
    }
    if (args.length >= 6) {
      zoom = parseInt(args[5], 10);
    }
    return resetMandel(plotMode, range);
  };

  canvasOnMouseDown = function(e) {
    var canvas, pnt, pxPnt, r, zoom, zoomFactor;

    e = e || window.event;
    canvas = document.getElementById("main_canvas");
    pxPnt = [e.clientX - canvas.offsetLeft, e.clientY - canvas.offsetTop];
    r = range[0][1] - range[0][0];
    pnt = [(pxPnt[0] / N) * r + range[0][0], (pxPnt[1] / N) * r + range[1][0]];
    zoomFactor = (e.which === 1 ? 2.0 : 0.5);
    zoom = MAX_RANGE / r;
    return zoomMandel(pnt, zoom * zoomFactor);
  };

  zoomMandel = function(pnt, factor) {
    var r;

    if (pnt === null) {
      pnt = [(range[0][0] + range[0][1]) / 2, (range[1][0] + range[1][1]) / 2];
    }
    r = range[0][1] - range[0][0];
    moveRange(pnt, MAX_RANGE / factor);
    return resetMandel(getPlotmode());
  };

  resetMandel = function(plotMode, newRange) {
    var canvas, ctx, mandelPlane, zoom;

    step_count = 0;
    if (!newRange || isNaN(newRange[0][0]) || isNaN(newRange[0][1]) || isNaN(newRange[1][0]) || isNaN(newRange[1][1])) {
      newRange = range;
    }
    range = newRange;
    zoom = Math.round(MAX_RANGE / (range[0][1] - range[0][0]));
    $("#st-zoom").val(zoom);
    $("#per-link").attr("href", "\#" + plotMode + "," + range[0][0] + "," + range[0][1] + "," + range[1][0] + "," + range[1][1] + "," + zoom);
    mandelPlane = (function() {
      var PIXS, c, dx, dy, i, j, ret;

      ret = [];
      PIXS = N;
      dx = (range[0][1] - range[0][0]) / PIXS;
      dy = (range[1][1] - range[1][0]) / PIXS;
      c = [range[0][0], range[1][0]];
      j = 0;
      while (j < PIXS) {
        c[0] = range[0][0];
        i = 0;
        while (i < PIXS) {
          ret[i + j * PIXS] = {
            c: [c[0], c[1]],
            z: [0, 0],
            it: 0
          };
          c[0] += dx;
          i++;
        }
        c[1] += dy;
        j++;
      }
      return ret;
    })();
    canvas = document.getElementById("main_canvas");
    ctx = canvas.getContext("2d");
    isAPointOutside = false;
    if (step_timer !== null) {
      clearInterval(step_timer);
    }
    step_timer = setInterval(step, 50, plotMode, mandelPlane, ctx);
    start_time = new Date().getTime();
    return $("#status").show();
  };

  step = function(plotMode, mandelPlane, ctx) {
    var colorChange, ret, walkCanvas;

    walkCanvas = function() {
      var abs_v, color, colorF, cpa, cpe, esc_radius, i, idx1, imd, ret_changed, ret_isapoint, _i, _ref;

      colorF = genColorList[plotMode];
      ret_changed = false;
      ret_isapoint = false;
      imd = ctx.getImageData(0, 0, N, N);
      cpa = imd.data;
      esc_radius = ESC_RADIUS;
      idx1 = 0;
      for (i = _i = 0, _ref = N * N; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        cpe = mandelPlane[i];
        if (cpe.out) {
          idx1 += 4;
          continue;
        }
        cpe.z = [cpe.z[0] * cpe.z[0] - cpe.z[1] * cpe.z[1] + cpe.c[0], 2 * cpe.z[0] * cpe.z[1] + cpe.c[1]];
        cpe.it++;
        abs_v = Math.sqrt(cpe.z[0] * cpe.z[0] + cpe.z[1] * cpe.z[1]);
        if (abs_v > esc_radius) {
          ret_isapoint = true;
          cpe.out = true;
        }
        color = cpe.out ? colorF(cpe) : [0, 0, 0];
        if ((ret_changed === false) && ((cpa[idx1] !== color[0]) || (cpa[idx1 + 1] !== color[1]) || (cpa[idx1 + 2] !== color[2]))) {
          ret_changed = true;
        }
        cpa[idx1++] = color[0];
        cpa[idx1++] = color[1];
        cpa[idx1++] = color[2];
        cpa[idx1++] = 255;
      }
      ctx.putImageData(imd, 0, 0);
      return {
        changed: ret_changed,
        isapoint: ret_isapoint
      };
    };
    ret = walkCanvas();
    colorChange = ret.changed;
    isAPointOutside = isAPointOutside || ret.isapoint;
    $("#st-step").text(++step_count);
    $("#time").text((new Date().getTime() - start_time) / 1000.0);
    if ((colorChange === false) && (isAPointOutside === true)) {
      if (step_timer !== null) {
        clearInterval(step_timer);
      }
      step_timer = null;
      return $("#status").hide();
    }
  };

}).call(this);
