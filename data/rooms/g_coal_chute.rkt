(define (slide-away! player tile)
  (send player say "YOU FALL INTO THE BASEMENT!"))

(define-room 
  [name "coal chute"]
  [floors '(ground)]
  [doors '(north)]
  [floorplan
   '("  \\.../  "
     "   |~|   "
     "   |~|   "
     "   |~|   "
     "__ \\ / __"
     "~~\\ | /~~"
     "~~~-O-~~~"
     "__/   \\__"
     "         ")]
  [tiles
   (list
    (define-tile
      [tile "\\"]
      [name "coal chute"]
      [description "a chute directly into the basement"]
      [walkable #t]
      [on-walk slide-away!])
    (define-tile
      [tile "/"]
      [name "coal chute"]
      [description "a chute directly into the basement"]
      [walkable #t]
      [on-walk slide-away!])
    (define-tile
      [tile "~"]
      [name "coal chute"]
      [description "a chute directly into the basement"]
      [walkable #t]
      [on-walk slide-away!])
    (define-tile
      [tile "|"]
      [name "coal chute"]
      [description "a chute directly into the basement"]
      [walkable #t]
      [on-walk slide-away!])
    (define-tile
      [tile "-"]
      [name "coal chute"]
      [description "a chute directly into the basement"]
      [walkable #t]
      [on-walk slide-away!])
    (define-tile
      [tile "_"]
      [name "coal chute"]
      [description "a chute directly into the basement"]
      [walkable #t]
      [on-walk slide-away!])
    (define-tile
      [tile "O"]
      [name "coal chute"]
      [description "a chute directly into the basement"]
      [walkable #t]
      [on-walk slide-away!]))])