
YParser = require './lib/index'

test = new YParser

test.loadString """(blah (+ 1 2) "toto" (32a 492))
(pow 4 2)
(map [1 2 3] +)
(map #["a" 42 "c" 23 "d" 21] /)
"""

test.addTokRule 'PO', -> @readChar '('
test.addTokRule 'PC', -> @readChar ')'
test.addTokRule 'BO', -> @readChar '['
test.addTokRule 'BC', -> @readChar ']'
test.addTokRule 'HASH', -> @readText "#["

test.addTokRule 'STR', ->
  if not @readChar '"'
    return false
  while true
    if @readChar '"'
      return true
    if @readText '\\"'
      continue
    if not @readAny()
      return false
  return false

test.addTokRule 'ID', ->
  if @readSpaces() or (@readChar '(') or (@readChar ')') or (@readChar "\n")
    return false
  if @readInt() and (@peekSpace() or @peekChar ')')
    return false
  if (@peekChar '[') or (@peekChar ']')
    return false
  while not @isEnd()
    if @peekSpace() or (@peekChar '(') or (@peekChar ')')
      break
    if (@peekChar "\n") or (@peekChar '[') or (@peekChar ']')
      break
    @readAny()
  return true

test.addTokRule 'SPACE', ->
  if not (@readSpaces() or @readEOL())
    return false
  while @readSpaces() or @readEOL()
    null
  return true

test.addTokRule 'INT', -> @readInt()

# test.addHandler

test.addRule "main", (ast) ->
  @readToken "SPACE", "*"
  while @parse "list", ast.new "list"
    @readToken "SPACE", "*"
    if @isEndToken()
      return true
  @error()
  return false

test.addRule "nativeToken", (ast) ->
  legitTypes = ['INT', 'ID', 'STR']
  token = @getToken()
  if token is null
    return false
  if (legitTypes.indexOf token.type) is -1
    console.log token
    @error token
    return false
  ast.addToken token

test.addRule "token", (ast) ->
  if @parse "list", ast
    return true
  if @parse "array", ast
    return true
  if @parse "hash", ast
    return true
  if @parse "nativeToken", ast
    return true
  return false

test.addRule "array", (ast) ->
  return false if not @readToken "BO"

  curAst = new YParser.Ast "array"
  while (@peekToken "BC") is null
    @readToken "SPACE", "*"
    if not @parse "token", curAst
      return false

  if not @readToken "BC"
    return false
  ast.nodes.push curAst
  return true

test.addRule "hash", (ast) ->
  return false if not @readToken "HASH"

  curAst = new YParser.Ast "hash"
  while (@peekToken "BC") is null
    @readToken "SPACE", "*"
    duet = new YParser.Ast "duet"
    if not @parse "token", duet
      return false
    @readToken "SPACE", "*"
    if not @parse "token", duet
      return false
    curAst.nodes.push duet

  if not @readToken "BC"
    return false
  ast.nodes.push curAst
  return true

test.addRule "list", (ast) ->
  return false if not @readToken "PO"

  curAst = new YParser.Ast "list"
  while (@peekToken "PC") is null
    @readToken "SPACE", "*"
    if not @parse "token", curAst
      return false

  if not @readToken "PC"
    return false
  ast.nodes.push curAst
  return true

test.setBreakOnUnknownToken()
test.init()
test.parse()

console.log JSON.stringify test.ast, null, 2

