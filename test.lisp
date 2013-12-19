(defun 'print ['str _]
  ('console.log str))
(set ['a 5
      'b 42
      't '(0 1 2 3 4 5 6 7 8 9)
      'toto "blah"
      ])
(defun 'mult ['list_ _]
  (for list_ ['id Number
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
