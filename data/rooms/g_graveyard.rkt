(define-room 
  [name "graveyard"]
  [description "a tucked away portion of grass, crumbling tombstones lying in shadows"]
  [floors '(ground)]
  [doors '(south)]
  [floorplan
   '("......-.."
     "..-..-..-"
     "........."
     "...-..-.."
     "...~....."
     "...~....."
     "........."
     "........."
     ".........")]
  [tiles
   (list
    (define-tile
      [tile "."]
      [name "grass"]
      [description "overly green grass"]
      [foreground "green"])
    (define-tile
      [tile "-"]
      [name "tombstone"]
      [foreground "gray"]
      [description "a rough marble headstone, the date of death many, many years ago"])
    (define-tile
      [tile "~"]
      [default-tile " "]
      [rotated-tile " "]
      [background "brown"]
      [name "open grave"]
      [description "do you really need to ask?"]
      [walkable #t]
      [on-walk
       (lambda (player tile)
         (send player die "You fall into an open grave and cannot escape.\nLooking up, you notice the name on the grave.\nIt is your own."))]))])