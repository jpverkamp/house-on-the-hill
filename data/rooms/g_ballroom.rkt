(define-room 
  [name "ballroom"]
  [description "a once grand ballroom, now fallen into disuse"]
  [floors '(ground)]
  [doors '(north south west east)]
  [floorplan
   '("O.....[=]"
     ".......-."
     "........."
     "........."
     "........."
     "........."
     "........."
     "........."
     ".........")]
  [tiles
   (list
    (define-tile
      [tile "O"]
      [name "table"]
      [description "a round table, shoved into the corner to clear the floor"]
      [walkable #f])
    (define-tile
      [tile "["]
      [name "piano"]
      [background "brown"]
      [description "a grand piano, in pristine condition despite its apparent age"]
      [walkable #f])
    (define-tile
      [tile "="]
      [name "piano"]
      [description "a grand piano, in pristine condition despite its apparent age"]
      [walkable #f])
    (define-tile
      [tile "]"]
      [name "piano"]
      [background "brown"]
      [description "a grand piano, in pristine condition despite its apparent age"]
      [walkable #f])
    (define-tile 
      [tile "-"]
      [name "piano bench"]
      [foreground "brown"]
      [description "a bench for the grand piano; one leg is noticibly shorter than rest"]))])