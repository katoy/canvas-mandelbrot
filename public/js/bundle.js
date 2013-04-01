/*
 * Returns 1 for TRUE boolean values, 0 for FALSE to be used in
 * arithmetical calculations.
 * 
 * @param b
*/

var ITERATION_LIMIT, MAX_COLORS, MAX_CONTROL_COLORS, MAX_SCALE, backImage, booleanToInt, colors, computeColors, computeMandel, controlColors, convertToPng, ctx, currX, currY, drawPixel, iCanvasHeight, iCanvasWidth, iCanvasX, iCanvasY, inRange, initMandel, lastColor, loop_max, mandelPixels, mbX, mbY, mouseDown, newY, onMouseDown, onMouseMove, onMouseUp, onTouchEnd, onTouchMove, onTouchStart, pmax, pmin, qmax, qmin, random, randomFloat, randomFloatRange, randomRange, randomSignedNoZero, report_Timing, resetControlColors, resetMandel, set_loop_max, set_mousepos, set_mousepos_x, set_mousepos_y, set_scale, show_loop_max, show_mousepos, show_scale, textOut, timeInMillis, wheel, wheelhandle, zoomMandel;

booleanToInt = function(b) {
  if (b) {
    return 1;
  } else {
    return 0;
  }
};

/*
 * Returns a random number between 0..n-1
 * @param n
*/


random = function(n) {
  return Math.floor(Math.random() * n);
};

/*
 * Returns a random number between n1..n2 inclusive
 * @param n1
 * @param n2
*/


randomRange = function(n1, n2) {
  return Math.floor(Math.random() * (n2 - n1 + 1)) + n1;
};

/*
 * Returns a random number between -(n-1)..(n-1) except 0.
 * For exammple a n=3 will give you -3,-2,-1,1,2,3 as possible answers
 * @param n
*/


randomSignedNoZero = function(n) {
  var i;

  i = random(n * 2) - n + 1;
  if (i < 1) {
    return i - 1;
  } else {
    return i;
  }
};

/*
 * Returns a floating point random between [0..n)
 * @param n
*/


randomFloat = function(n) {
  return Math.random() * n;
};

/*
 * Returns a floating point random between [n1..n2)
 * @param n1 from
 * @param n2 to
*/


randomFloatRange = function(n1, n2) {
  return Math.random() * (n2 - n1) + n1;
};

/*
 * Returns the current time in milliseconds since 1970
*/


timeInMillis = function() {
  return (new Date()).getTime();
};

/*
 * Returns TRUE if x is between start and finish (non inclusive)
 * 
 * @param x
 * @param start
 * @param finish
*/


inRange = function(x, start, finish) {
  return (x >= start) && (x < finish);
};

iCanvasWidth = null;

iCanvasHeight = null;

ctx = null;

mandelPixels = null;

iCanvasX = null;

iCanvasY = null;

currX = null;

currY = null;

newY = null;

mouseDown = null;

mbX = null;

mbY = null;

backImage = null;

MAX_CONTROL_COLORS = 5;

MAX_COLORS = 512;

ITERATION_LIMIT = 100;

loop_max = 2560;

controlColors = new Array(MAX_CONTROL_COLORS);

colors = new Array(MAX_COLORS);

pmin = -2.25;

pmax = 0.75;

qmin = -1.5;

qmax = 1.5;

lastColor = 0;

textOut = function(s, x, y) {
  ctx.textBaseline = "top";
  ctx.font = "10px 'Tahoma, Verdana, Arial, Helvetica'";
  ctx.lineWidth = 2;
  ctx.strokeStyle = "#001";
  ctx.strokeText(s, x, y);
  ctx.fillStyle = "#eeb";
  return ctx.fillText(s, x, y);
};

report_Timing = function(msg) {
  if (false) {
    textOut(msg, 4, 4);
    textOut("x: " + pmin + " .. " + pmax, 4, 16);
    textOut("y: " + qmin + " .. " + qmax, 4, 28);
    return textOut("zoom: " + (zoomStr(pmin, pmax)), 4, 40);
  } else {
    return $("#info_time").text("" + msg);
  }
};

show_scale = function() {
  var str;

  str = (3.0 / (pmax - pmin)).toFixed(2);
  return $("#info_scale").val(str);
};

set_scale = function(v) {
  var p0, pmax0, pmin0, pw_half, q0, qmax0, qmin0, qw_half;

  if (isNaN(v)) {
    return false;
  }
  if (v > MAX_SCALE) {
    return false;
  }
  p0 = (pmin + pmax) / 2.0;
  q0 = (qmin + qmax) / 2.0;
  pw_half = 3.0 / (2.0 * v);
  qw_half = 3.0 / (2.0 * v);
  pmin0 = p0 - pw_half;
  pmax0 = p0 + pw_half;
  qmin0 = q0 - qw_half;
  qmax0 = q0 + qw_half;
  if (3.0 / (pmax0 - pmin0) > MAX_SCALE) {
    return false;
  }
  pmin = pmin0;
  pmax = pmax0;
  qmin = qmin0;
  qmax = qmax0;
  return show_scale();
};

show_loop_max = function() {
  return $("#info_loop_max").val(loop_max);
};

set_loop_max = function(v) {
  loop_max = v;
  return show_loop_max();
};

show_mousepos = function(x, y) {
  var xinfoStr, yinfoStr;

  xinfoStr = "x: " + pmin + " .. " + pmax + " x0: " + ((pmax + pmin) / 2.0);
  yinfoStr = "y: " + qmin + " .. " + qmax + " y0: " + ((qmax + qmin) / 2.0);
  $("#info_x").text(xinfoStr);
  $("#info_y").text(yinfoStr);
  $("#info_mousepos_x").val(x);
  return $("#info_mousepos_y").val(y);
};

set_mousepos_x = function(x) {
  return set_mousepos(x, (qmin + qmax) / 2.0);
};

set_mousepos_y = function(y) {
  return set_mousepos((pmin + pmax) / 2.0, y);
};

set_mousepos = function(x, y) {
  var dx, dy, p0, q0;

  x = parseFloat(x);
  y = parseFloat(y);
  p0 = (pmin + pmax) / 2.0;
  q0 = (qmin + qmax) / 2.0;
  dx = x - p0;
  dy = y - q0;
  pmin = pmin + dx;
  pmax = pmax + dx;
  qmin = qmin + dy;
  return qmax = qmax + dy;
};

/*
 * Draw a Pixel on the canvas context. This method is caching the last color used
 * as the ctx.fillStyle is an expensive method.
 * 
 * @param x
 * @param y
 * @param c
*/


drawPixel = function(x, y, c) {
  var iOffset;

  iOffset = 4 * (y * iCanvasWidth + x);
  mandelPixels[iOffset] = colors[c][0];
  mandelPixels[iOffset + 1] = colors[c][1];
  mandelPixels[iOffset + 2] = colors[c][2];
  return mandelPixels[iOffset + 3] = 255;
};

/*
 *
*/


resetMandel = function(w, h) {
  var scale;

  scale = 3.0 / h;
  pmin = -(9.0 / 12.0) * w * scale;
  pmax = (3.0 / 12.0) * w * scale;
  qmin = -1.5;
  qmax = 1.5;
  show_mousepos((pmin + pmax) / 2.0, (qmin + qmax) / 2.0);
  show_loop_max();
  return show_scale();
};

MAX_SCALE = 1.0e14;

zoomMandel = function(scale) {
  var pc, pw, qc, qw;

  pw = (pmax - pmin) / scale;
  qw = (qmax - qmin) / scale;
  if ((scale > 1) && (3.0 / pw > MAX_SCALE || 3.0 / qw > MAX_SCALE)) {
    return false;
  }
  pc = (pmax + pmin) / 2.0;
  pmin = pc - pw / 2.0;
  pmax = pc + pw / 2.0;
  qc = (qmax + qmin) / 2.0;
  qmin = qc - qw / 2.0;
  qmax = qc + qw / 2.0;
  return true;
};

/*
 *
*/


resetControlColors = function() {
  controlColors[0] = [0x00, 0x00, 0x20];
  controlColors[1] = [0xff, 0xff, 0xff];
  controlColors[2] = [0x00, 0x00, 0xa0];
  controlColors[3] = [0x40, 0xff, 0xff];
  return controlColors[4] = [0x20, 0x20, 0xff];
};

/*
 *
*/


computeColors = function() {
  var bstep, gstep, i, k, rstep, _results;

  colors[0] = [0, 0, 0];
  i = 0;
  while (i < MAX_CONTROL_COLORS - 1) {
    rstep = (controlColors[i + 1][0] - controlColors[i][0]) / 63;
    gstep = (controlColors[i + 1][1] - controlColors[i][1]) / 63;
    bstep = (controlColors[i + 1][2] - controlColors[i][2]) / 63;
    k = 0;
    while (k < 64) {
      colors[k + (i * 64) + 1] = [Math.round(controlColors[i][0] + rstep * k), Math.round(controlColors[i][1] + gstep * k), Math.round(controlColors[i][2] + bstep * k)];
      k++;
    }
    i++;
  }
  i = 257;
  _results = [];
  while (i < MAX_COLORS) {
    colors[i] = colors[i - 256];
    _results.push(i++);
  }
  return _results;
};

computeMandel = function() {
  var KMAX, elapsed, k, mandelImage, p, q, r, start, sx, sy, x, x0, xstep, y, y0, ystep;

  KMAX = 256;
  loop_max;
  xstep = (pmax - pmin) / iCanvasWidth;
  ystep = (qmax - qmin) / iCanvasHeight;
  x = 0.0;
  y = 0.0;
  r = 1.0;
  mandelImage = ctx.getImageData(0, 0, iCanvasWidth, iCanvasHeight);
  mandelPixels = mandelImage.data;
  start = new Date().getTime();
  sy = 0;
  report_Timing("caluclationg ...");
  while (sy < iCanvasHeight) {
    sx = 0;
    while (sx < iCanvasWidth) {
      p = pmin + xstep * sx;
      q = qmax - ystep * sy;
      k = 0;
      x0 = 0.0;
      y0 = 0.0;
      while (true) {
        x = x0 * x0 - y0 * y0 + p;
        y = 2 * x0 * y0 + q;
        x0 = x;
        y0 = y;
        r = x * x + y * y;
        k++;
        if (!((r <= ITERATION_LIMIT) && (k < loop_max))) {
          break;
        }
      }
      k = k % KMAX;
      drawPixel(sx, sy, k);
      sx++;
    }
    sy++;
  }
  ctx.putImageData(mandelImage, 0, 0);
  elapsed = new Date().getTime() - start;
  report_Timing("" + elapsed + " ms,");
  return show_scale();
};

onMouseDown = function(e) {
  e = window.event || e;
  mouseDown = true;
  mbX = e.offsetX || (e.clientX - iCanvasX);
  mbY = e.offsetY || (e.clientY - iCanvasY);
  return backImage = ctx.getImageData(0, 0, iCanvasWidth, iCanvasHeight);
};

onMouseMove = function(e) {
  var x0, y0;

  e = window.event || e;
  currX = e.offsetX || (e.clientX - iCanvasX);
  currY = e.offsetY || (e.clientY - iCanvasY);
  if (mouseDown) {
    newY = mbY + (booleanToInt(currY > mbY) * 2 - 1) * Math.round(iCanvasHeight * Math.abs(currX - mbX) / iCanvasWidth);
    ctx.putImageData(backImage, 0, 0);
    ctx.strokeStyle = "rgb(170,255,65)";
    ctx.strokeRect(mbX, mbY, currX - mbX, newY - mbY);
  }
  x0 = pmin + currX * (pmax - pmin) / iCanvasWidth;
  y0 = qmax - currY * (qmax - qmin) / iCanvasHeight;
  return show_mousepos(x0, y0);
};

onMouseUp = function(e) {
  var hx, hy, newX, p0, pDiff, pw, q0, qDiff, qw;

  e = window.event || e;
  if (mouseDown) {
    currX = e.offsetX || (e.clientX - iCanvasX);
    currY = e.offsetY || (e.clientY - iCanvasY);
    newX = currX;
    newY = mbY + (booleanToInt(currY > mbY) * 2 - 1) * Math.round(iCanvasHeight * Math.abs(currX - mbX) / iCanvasWidth);
    if (newX < mbX) {
      hx = newX;
      newX = mbX;
      mbX = hx;
    }
    if (newY < mbY) {
      hy = newY;
      newY = mbY;
      mbY = hy;
    }
    console.log(mbX + ", " + mbY + " to " + newX + ", " + newY);
    if ((Math.abs(newX - mbX) > 3) && (Math.abs(newY - mbY) > 3)) {
      pw = pmax - pmin;
      qw = qmax - qmin;
      if (3.0 / pw < MAX_SCALE && 3.0 / qw < MAX_SCALE) {
        pmin = pmin + mbX * pw / iCanvasWidth;
        pmax = pmax - (iCanvasWidth - newX) * pw / iCanvasWidth;
        qmin = qmin + (iCanvasHeight - newY) * qw / iCanvasHeight;
        qmax = qmax - mbY * qw / iCanvasHeight;
        computeMandel();
      }
    } else {
      p0 = pmin + newX * (pmax - pmin) / iCanvasWidth;
      q0 = qmax - newY * (qmax - qmin) / iCanvasHeight;
      pDiff = (pmin + pmax) / 2.0 - p0;
      qDiff = (qmin + qmax) / 2.0 - q0;
      pmin -= pDiff;
      pmax -= pDiff;
      qmin -= qDiff;
      qmax -= qDiff;
      computeMandel();
    }
  }
  return mouseDown = false;
};

onTouchStart = function(e) {
  var touch;

  e.preventDefault();
  touch = e.targetTouches[0];
  mouseDown = true;
  mbX = touch.pageX - iCanvasX;
  mbY = touch.pageY - iCanvasY;
  return backImage = ctx.getImageData(0, 0, iCanvasWidth, iCanvasHeight);
};

onTouchMove = function(e) {
  var p0, q0, tcurrX, tcurrY, touch;

  e.preventDefault();
  touch = e.targetTouches[0];
  if (mouseDown) {
    tcurrX = touch.pageX - iCanvasX;
    tcurrY = touch.pageY - iCanvasY;
    newY = mbY + (booleanToInt(tcurrY > mbY) * 2 - 1) * Math.round(iCanvasHeight * Math.abs(tcurrX - mbX) / iCanvasWidth);
    ctx.putImageData(backImage, 0, 0);
    ctx.strokeStyle = "rgb(170,255,65)";
    ctx.strokeRect(mbX, mbY, tcurrX - mbX, newY - mbY);
    tcurrY = newY;
  }
  p0 = pmin + tcurrX * (pmax - pmin) / iCanvasWidth;
  q0 = qmax - tcurrY * (qmax - qmin) / iCanvasHeight;
  return show_mousepos(p0, q0);
};

onTouchEnd = function(e) {
  var hx, hy, newX, pw, qw, touch;

  touch = e.targetTouches[0];
  if (mouseDown) {
    newX = tcurrX;
    newY = tcurrY;
    if (newX < mbX) {
      hx = newX;
      newX = mbX;
      mbX = hx;
    }
    if (newY < mbY) {
      hy = newY;
      newY = mbY;
      mbY = hy;
    }
    if ((Math.abs(newX - mbX) > 3) && (Math.abs(newY - mbY) > 3)) {
      pw = pmax - pmin;
      qw = qmax - qmin;
      if (3.0 / pw < MAX_SCALE && 3.0 / qw < MAX_SCALE) {
        pmin = pmin + mbX * pw / iCanvasWidth;
        pmax = pmax - (iCanvasWidth - newX) * pw / iCanvasWidth;
        qmin = qmin + (iCanvasHeight - newY) * qw / iCanvasHeight;
        qmax = qmax - mbY * qw / iCanvasHeight;
      }
      computeMandel();
    }
  }
  return mouseDown = false;
};

wheel = function(event) {
  var delta;

  delta = 0;
  event = window.event || event;
  if (event.wheelDelta) {
    delta = event.wheelDelta / 120;
  } else if (event.detail) {
    delta = -event.detail / 3;
  }
  if (delta !== 0) {
    wheelhandle(delta);
  }
  if (event.preventDefault) {
    event.preventDefault();
  }
  return event.returnValue = false;
};

wheelhandle = function(delta) {
  var scale;

  scale = delta < 0 ? 0.8 : 1.2;
  if (zoomMandel(scale)) {
    return computeMandel();
  }
};

/*
 * Converts the canvas to a PNG and modifies the document location to it
 * 
 * @param canvasElement
*/


convertToPng = function(canvasElement, outputElement) {
  var canvas, newwindow, url;

  canvas = document.getElementById(canvasElement);
  url = canvas.toDataURL();
  return newwindow = window.open(url, "PNG image of canvas");
};

/*
 * @param canvasElement
 * @param w
 * @param h
*/


initMandel = function(canvasElement, w, h) {
  var canvas;

  iCanvasWidth = w;
  iCanvasHeight = h;
  canvas = document.getElementById(canvasElement);
  ctx = canvas.getContext("2d");
  canvas.width = w;
  canvas.height = h;
  iCanvasX = canvas.offsetLeft;
  iCanvasY = canvas.offsetTop;
  resetMandel(w, h);
  resetControlColors();
  computeColors();
  canvas.onmousedown = onMouseDown;
  canvas.onmousemove = onMouseMove;
  canvas.onmouseup = onMouseUp;
  if (canvas.addEventListener) {
    canvas.addEventListener('DOMMouseScroll', wheel, false);
  }
  canvas.onmousewheel = wheel;
  canvas.addEventListener("touchstart", onTouchStart);
  canvas.addEventListener("touchmove", onTouchMove);
  canvas.addEventListener("touchend", onTouchEnd);
  return console.log("+ canvas initialised at " + iCanvasX + " " + iCanvasY);
};
