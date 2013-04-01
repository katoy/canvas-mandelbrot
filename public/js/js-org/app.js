function resetPresetStyles () {
    for (var i = 0; i < 8; i++) {
        document.getElementById("preset_" + i).className = "";
    }
};

function load (element, w, h) {    
    // initLogger();
    if (element) {
        resetPresetStyles();
        element.className = "selected";
    }
    initMandel("canvas", w, h);
    computeMandel();
};

