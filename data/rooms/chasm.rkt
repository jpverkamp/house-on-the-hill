(define-room
  [name "chasm"]
  [floors '(basement)]
  [doors '(west east)]
  [floorplan
   '("         "
     "         "
     "         "
     "||| |||||"
     "|||||| ||"
     "|||||||||"
     "         "
     "         "
     "         ")]
  [tiles
   (list 
    (define-tile
      [tile " "]
      [name "empty space"]
      [description "a seemingly endless drop into darkness"]
      [on-walk
       (lambda (player tile)
         (when (send player ask "Are you sure you want to step into the empty space?")
           (send player die "You fall screaming into the abyss.")))])
   (define-tile
     [tile "|"]
     [rotated-tile "-"]
     [name "rickety bridge"]
     [description "half rotten planks of wood; they look like they might break at any moment"]
     [on-walk
      (lambda (player tile)
        (send tile set-param 'steps (+ 1 (send tile get-param 'steps 0)))
        (define steps (send tile get-param 'steps 0))
        (cond
          [(and (>= steps 5) (> (random) 0.5))
           (send player die 
                 "The step beneath you gives way, plunging you into the endless abyss.")]
          [(or (= steps 2)
               (and (> steps 2) (> (random) 0.5)))
           (send player say 
                 "The step beneath you creaks, threatening to give way at any moment.")]))]))])