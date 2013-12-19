
fs = require 'fs'
YParser = require './lib/index'

grammarFile = null

class Test3Class extends YParser.GrammarParser
  constructor: ->
    super()
    @loadGrammarFile()
    @lists = new Array

  loadGrammarFile: ->
    if grammarFile is null
      grammarFile = fs.readFileSync "grammar.json", 'ascii'
    @loadJson grammarFile

  newList: (ast) ->
    parser.lists.push ast
    return true

  setRaw: (ast) ->
    ast.nodes[-1..][0].raw = true
    return true

  parse: (str) ->
    @loadString str
    @init()
    if not super "main"
      @error()

module.exports = Test3Class

