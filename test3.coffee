
fs = require 'fs'
Parser = require './test3_class'

testFile = fs.readFileSync 'test.lisp', 'ascii'

parser = new Parser

parser.parse testFile

console.log JSON.stringify parser.ast, null, 2

