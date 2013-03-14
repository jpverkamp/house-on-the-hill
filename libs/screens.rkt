#lang racket

(provide 
 screen%
 main-menu-screen%
 game-screen%)

(require
 racket/gui
 racket/draw
 "room.rkt")

; basic screen
; we shouldn't actually use this one
(define screen%
  (class object%
    ; called whenever the user presses a key
    ; return the screen for the next frame (will generally be this)
    ; override this
    (define/public (update key-event)
      (error 'screen% "override this method"))
    
    ; called whenever the user draws something
    ; override this
    (define/public (draw canvas)
      (error 'screen% "override this method"))
    
    (super-new)))

; main menu screen, just wait for a key press
(define main-menu-screen%
  (class screen%
    (define/override (update key-event)
      (printf "make the game\n")
      (new game-screen%))
    
    (define/override (draw canvas)
      (send canvas draw-centered-string 10 "The House on the Hill")
      (send canvas draw-centered-string 12 "Press any key to begin"))
    
    (super-new)))

; the main game screen, most everything will happen here
(define game-screen%
  (class screen%
    ; hash of (floor x y) => room
    (define rooms (make-hash))
    
    ; player position
    (define player-floor 'ground)
    (define player-x 0)
    (define player-y 0)
    
    ; add the initial room
    (hash-set! rooms '(ground  0  0) (get-room 'outside))
    (hash-set! rooms '(ground  0 -1) (get-room 'catacombs))
    (hash-set! rooms '(ground -1 -1) (get-room 'chasm))
    
    (define/override (update key-event)
      (case (send key-event get-key-code)
        [(up #\w) 
         (printf "move north\n")
         (set! player-y (add1 player-y))]
        [(down #\s)
         (printf "move south\n")
         (set! player-y (sub1 player-y))]
        [(left #\a)
         (printf "move west\n")
         (set! player-x (add1 player-x))]
        [(right #\d)
         (printf "move east\n")
         (set! player-x (sub1 player-x))])
      this)
    
    (define/override (draw canvas)
      (send canvas clear)
      
      ; get the canvas size
      (define wide (send canvas get-tiles-wide))
      (define high (send canvas get-tiles-high))
      
      ; special rounding function
      (define (div10 x) (inexact->exact (floor (/ x 10))))

      ; --- draw the rooms ---
      (for* ([xi (in-range wide)]
             [yi (in-range high)])
        
        ; get the offset
        (define x (- xi player-x (quotient wide 2) -4))
        (define y (- yi player-y (quotient high 2) -4))

        ; draw the tile
        (cond
          ; draw walls between rooms
          [(or (= 9 (modulo x 10))
               (= 9 (modulo y 10)))
           (send canvas draw-tile xi yi #\space "white" "white")
           
           ; --- check for doors ---
           
           ; south
           (for ([x/y (in-list (list x x y y))]
                 [xd (in-list '(0 0 -5 5))]
                 [yd (in-list '(-5 5 0 0))]
                 [dir (in-list '(north south west east))])
             (cond 
               [(and (<= 3 x/y 5)
                     (hash-ref rooms (list player-floor 
                                           (div10 (- x xd))
                                           (div10 (- y yd))) 
                               #f))
                => (lambda (room)
                     (when (send room has-door? dir)
                       (send canvas draw-tile xi yi #\= "white" "brown")))]))]
          
          ; otherwise, get the room
          [(hash-ref rooms (list player-floor (div10 x) (div10 y)) #f)
           => (lambda (room)
                (define tile (send room get-tile (modulo x 10) (modulo y 10)))
                (send canvas draw-tile xi yi
                      (send tile get-tile)
                      (send tile get-foreground)
                      (send tile get-background)))]))
     ; draw the player
      (send canvas draw-tile (quotient wide 2) (quotient high 2) #\@))
    
    (super-new)))