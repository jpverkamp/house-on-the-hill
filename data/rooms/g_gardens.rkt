(define-room 
  [name "gardens"]
  [floors '(ground)]
  [doors '(north south)]
  [floorplan
   '("...,,,..."
     "..,,,...."
     "..,,,...."
     "...,,,~.."
     "...,,,~.."
     "...,,,..."
     "....,,,.."
     "...,,,..."
     "...,,,...")]
  [tiles
   (list
    (define-tile
      [tile "."]
      [name "grass"]
      [description "overly green grass"]
      [foreground "green"])
    (define-tile
      [tile ","]
      [default-tile "."]
      [rotated-tile "."]
      [name "path"]
      [foreground "gray"]
      [description "a winding path, with small stones on either side"])
    (define-tile
      [tile "~"]
      [default-tile " "]
      [rotated-tile " "]
      [background "gray"]
      [name "table"]
      [description "s tone table, it's surface scarred and pitted"]
      [walkable #f]))])