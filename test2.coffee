
fs = require 'fs'

YParser = require './lib/index'
Generator = YParser.Generator

bnf = """

LO = '(' ;
LC = ')' ;
HO = '[' ;
HC = ']' ;
raw = "'" ;
str = '"' ['\\\\"' | any ^ '"']* '"' ;
anyspaces = anyspaces ;
int = int @[any ^ id];
id = [[any ^ [LO | LC | HO | HC | '"' | "'" | anyspace]]+
  ^ [passkey | defun | if_ | set_ | for_ | while_ | switch_ | lambda_ ]] ;
defun = 'defun' ;
if_ = 'if' ;
set_ = 'set' ;
for_ = 'for' ;
while_ = 'while' ;
switch_ = 'switch' ;
lambda_ = 'lambda' ;
passkey = '_' ;

main :: token+ anyspaces? eof
  ;

list :: list(newList)#_list ;
_list ::
  anyspaces? LO
  [ anyspaces? token ]*
  anyspaces? !LC
  ;

token :: plain_token | _token
  ;

_token ::
    function
  | if
  | for
  | set
  | while
  | switch
  | lambda
  | funccall
  | list
  | hash
  | id:id
  | passkey:passkey
  | int(toNumber):int
  | str(cleanStr):str
  ;

plain_token :: raw _token (setRaw)
  ;

if :: if#_if ;
_if ::
  anyspaces? LO
  anyspaces? if_
  anyspaces? !condition#token
  anyspaces? !cond_true#token
  [anyspaces? cond_false#token]?
  anyspaces? !LC
  ;

for :: for#_for ;
_for ::
  anyspaces? LO
  anyspaces? for_
  anyspaces? !var#token
  anyspaces? !unpack#_hash
  anyspaces? !body#token
  anyspaces? !LC
  ;

set :: set#_set ;
_set ::
  anyspaces? LO
  anyspaces? set_
  anyspaces? !vars#_hash
  anyspaces? !LC
  ;

while :: while#_while | while#_while_cond | _while_error ;

_while ::
  anyspaces? LO
  anyspaces? while_
  anyspaces? body#token
  anyspaces? LC
  ;

_while_cond ::
  anyspaces? LO
  anyspaces? while_
  anyspaces? !condition#token
  anyspaces? !body#token
  anyspaces? !LC
  ;

_while_error ::
  anyspaces? LO
  anyspaces? while_
  (error)
  ;

switch :: switch#_switch ;
_switch ::
  anyspaces? LO
  anyspaces? switch_
  anyspaces? !var#token
  anyspaces? !switch_body#_hash
  anyspaces? !LC
  ;

lambda :: lambda#_lambda ;
_lambda ::
  anyspaces? LO
  anyspaces? lambda_
  [anyspaces? arguments#_hash]?
  anyspaces? !body#token
  anyspaces? !LC
  ;

function :: defun#_function ;
_function ::
  anyspaces? LO
  anyspaces? defun
  anyspaces? !funcName#token
  [anyspaces? arguments#_hash]?
  anyspaces? !body#token
  anyspaces? !LC
  ;

funccall :: call#_funccall ;
_funccall ::
  anyspaces? LO
  anyspaces? callName#token
  args#[anyspaces? token]*
  anyspaces? !LC
  ;

hash :: hash#_hash ;
_hash ::
  anyspaces? HO
  [ anyspaces? duet ]*
  anyspaces? !HC
  ;

duet :: duet#_duet ;
_duet ::
  anyspaces? token
  anyspaces? !token
  ;

"""

test = """
(defun 'print ['str _]
  ('console.log str))
(set ['a 5
      'b 42
      't '(0 1 2 3 4 5 6 7 8 9)
      'toto "blah"
      ])
(defun 'mult ['list _]
  (for list ['id Number
             'item Number]
    (print (* item 2))))
(mult t)
(if (= a 5)
  (print "ahoy !")
  (print "prout !"))
(while (> b 0)
  ('_
    (print b)
    (set ['b (- b 1)])))
(switch toto
  [
    "hey"   (print "test 1")
    "hoy"   (print "test 2")
    "blah"  (print "test 4")
    _       (print "test ?")
  ])
(if true
  (print "blah"))
(map t
  (lambda [elem _
           id   Number
           tab  _]
    (print elem)))
"""

gene = new Generator bnf

parser = gene.generate()
# console.log JSON.stringify parser
# process.exit 0
parser.lists = []
parser.newList = (ast) ->
  parser.lists.push ast
parser.setRaw = (ast) ->
  ast.nodes[-1..][0].raw = true
  return true
parser.loadString test
parser.setBreakOnUnknownToken()
parser.init()
if not parser.parse()
  parser.error()

# console.log JSON.stringify parser._tokenRules['str_simple'], null, 2
# console.log JSON.stringify parser.tokens, null, 2
# console.log JSON.stringify parser.ast, null, 2
# console.log JSON.stringify parser._rules, null, 2

