
var ctx;
var ctxImage;         // holder of pixel data
var ctxPixels;        // holder of pixel data for canvas
var iCanvasWidth;
var iCanvasHeight;
var iCanvasX;
var iCanvasY;

var lastColor;

/**
 *
 * @param canvasElement
 * @param w
 * @param h
 */
function initCanvas (canvasElement, w, h) {
    var canvas = document.getElementById(canvasElement);
    ctx = canvas.getContext("2d");
    canvas.width = w;
    canvas.height = h;

    // get the size and position of the canvas on the page
    iCanvasWidth = canvas.width;
    iCanvasHeight = canvas.height;
    iCanvasX = canvas.offsetLeft;
    iCanvasY = canvas.offsetTop;
    
    // create a back image and get a pointer to the pixels array
    // See http://www.html5.jp/canvas/ref/method/getImageData.html
    ctxImage = ctx.getImageData(0, 0, iCanvasWidth, iCanvasHeight);
    ctxPixels = ctxImage.data;

    return canvas;
}

/**
 * Draw a Pixel on the canvas context. This method is caching the last color used
 * as the ctx.fillStyle is an expensive method.
 *
 * @param x
 * @param y
 * @param c
 */
function drawPixel ( x, y, c ) {
    if (lastColor != c) {
        lastColor = c;
        ctx.fillStyle = colors[c];
    }
    ctx.fillRect(x, y, 1, 1);
}

function drawLine ( x0, y0, x1, y1 ) {
    ctx.beginPath();
    ctx.moveTo(x0, y0);
    ctx.lineTo(x1, y1);
    ctx.stroke();
}

/**
 * Converts the canvas to a PNG and modifies the document location to it
 * 
 * @param canvasElement
 */
function convertToPng ( canvasElement, outputElement ) {
    var canvas = document.getElementById(canvasElement);
    // See http://www.html5.jp/canvas/ref/HTMLCanvasElement/toDataURL.html
    var url = canvas.toDataURL();    
    newwindow = window.open(url, 'canvas generated image');
}
