(define-room 
  [name "dining room"]
  [description "a beautiful oak table, still set with dinner for six"]
  [floors '(ground)]
  [doors '(north east)]
  [floorplan
   '("........."
     ".o......."
     "../-\\...."
     "..|~|...."
     "..|~|...."
     "..\\-/...."
     "......o.."
     ".o......."
     "...o.....")]
  [tiles
   (list
    (define-tile
      [tile "o"]
      [name "chair"]
      [background "brown"]
      [description "one of several scattered chairs, most tipped over and abandoned"]
      [walkable #f])
    (define-tile
      [tile "~"]
      [name "table"]
      [background "brown"]
      [description "a round table, set for a meal long ago"]
      [walkable #f])
    (define-tile
      [tile "-"]
      [name "table"]
      [background "brown"]
      [description "a round table, set for a meal long ago"]
      [walkable #f])
    (define-tile
      [tile "|"]
      [name "table"]
      [background "brown"]
      [description "a round table, set for a meal long ago"]
      [walkable #f])
    (define-tile
      [tile "\\"]
      [name "table"]
      [background "brown"]
      [description "a round table, set for a meal long ago"]
      [walkable #f])
    (define-tile
      [tile "/"]
      [name "table"]
      [background "brown"]
      [description "a round table, set for a meal long ago"]
      [walkable #f]))])