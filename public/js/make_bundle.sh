#!/bin/sh

cat util.coffee mandel.coffee > 1.coffee
coffee -p -b 1.coffee > bundle.js 
rm -f 1.coffee

coffee -p -b app.coffee > app.js
