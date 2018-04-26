var charsetDetector = require("node-icu-charset-detector");
var fs = require("fs");

var buffer = fs.readFileSync("UTF-8.txt");
var charset = charsetDetector.detectCharset(buffer);

console.log(charset.toString());