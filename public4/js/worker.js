// Generated by CoffeeScript 1.6.2
(function() {
  "use strict";
  var getColor32, getColorGray;

  self.addEventListener("message", (function(e) {
    var colorFunc, data, escape, i, iterations, iy, rx, x, x_step, y, y_end, y_start, y_step, zx, zx2, zy, zy2, _i, _j, _ref;

    x_step = e.data.view_range / e.data.width;
    y_step = e.data.view_range / e.data.height;
    y_start = e.data.height / e.data.worker_size * e.data.id;
    y_end = e.data.height / e.data.worker_size;
    data = new Int32Array(e.data.image.data.buffer);
    colorFunc = e.data.plotMode === "color32" ? getColor32 : getColorGray;
    escape = e.data.escape;
    iterations = e.data.iterations;
    for (y = _i = 0; 0 <= y_end ? _i < y_end : _i > y_end; y = 0 <= y_end ? ++_i : --_i) {
      iy = e.data.y_center - e.data.view_range / 2 + (y + y_start) * y_step;
      for (x = _j = 0, _ref = e.data.width; 0 <= _ref ? _j < _ref : _j > _ref; x = 0 <= _ref ? ++_j : --_j) {
        rx = e.data.x_center - e.data.view_range / 2 + x * x_step;
        zx = rx;
        zy = iy;
        zx2 = 0;
        zy2 = 0;
        i = 0;
        while (zx2 + zy2 < escape && i < iterations) {
          zx2 = zx * zx;
          zy2 = zy * zy;
          zy = (zx + zx) * zy + iy;
          zx = zx2 - zy2 + rx;
          ++i;
        }
        data[y * e.data.width + x] = colorFunc(i);
      }
    }
    return self.postMessage(e.data.image);
  }), false);

  getColorGray = function(ite) {
    ite = ite % 256;
    return (255 << 24) | (ite << 16) | (ite << 8) | ite;
  };

  getColor32 = function(ite) {
    var base, d, m, rgb;

    base = 32;
    d = (ite % base) * 256 / base;
    m = (d / 42.667) << 0;
    rgb = (function() {
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
    return (255 << 24) | rgb[0] << 16 | rgb[1] << 8 | rgb[2];
  };

}).call(this);