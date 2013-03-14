(define (border-warning player tile)
  (when (send player ask "Are you sure you want to leave?")
    (send player die "Too bad. You lose.")))

(define-room
  [name "outside"]
  [floors '()]
  [doors '(north)]
  [floorplan
   '("---===---"
     ".,,~~~,,."
     ".,,~~~,,."
     ".,,~~~,,."
     ".,,~~~,,."
     ".,,~~~,,."
     ".,,~~~,,."
     ".,,~~~,,."
     "...```...")]
  [tiles
   (list 
    (define-tile
      [tile "~"]
      [default-tile " "]
      [rotated-tile " "]
      [name "walkway"]
      [description "a cracked tile path, leading up to the front door"])
    (define-tile
      [tile "`"]
      [default-tile " "]
      [rotated-tile " "]
      [name "walkway"]
      [description "a cracked tile path, leading up to the front door"]
      [on-walk border-warning])
    (define-tile
      [tile ","]
      [default-tile "."]
      [rotated-tile "."]
      [name "grass"]
      [description "dried grass, slowly dying"])
    (define-tile
      [tile "."]
      [name "grass"]
      [description "dried grass, slowly dying"]
      [on-walk border-warning]))])