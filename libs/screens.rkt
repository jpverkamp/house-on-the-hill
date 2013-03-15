#lang racket

(provide 
 screen%
 main-menu-screen%
 game-screen%)

(require
 racket/gui
 racket/draw
 "room.rkt"
 "player.rkt")

; add or subtract one
(define-syntax-rule (++! var) (set! var (+ var 1)))
(define-syntax-rule (--! var) (set! var (- var 1)))

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
      (new game-screen%))
    
    (define/override (draw canvas)
      (send canvas draw-centered-string 10 "The House on the Hill")
      (send canvas draw-centered-string 12 "Press any key to begin"))
    
    (super-new)))

; main menu screen, just wait for a key press
(define loss-screen%
  (class screen%
    (define/override (update key-event)
      (new game-screen%))
    
    (define/override (draw canvas)
      (send canvas clear)
      (send canvas draw-centered-string 10 "The House on the Hill")
      (send canvas draw-centered-string 12 "You lose! :(")
      (send canvas draw-centered-string 14 "Press any key to try again"))
    
    (super-new)))

; the main game screen, most everything will happen here
(define game-screen%
  (class screen%
    ; hash of (floor x y) => room
    (define rooms (make-hash))
    
    ; --- player position ---
    (define player (make-player))
    (define player-floor 'ground)
    
    ; which room the player is in (start at 0x0)
    (define player-room-x 0)
    (define player-room-y 0)
    
    ; which block the player is at within the room
    ; the blocks within the room range from -4 to +4
    ; the walls around each room are at -5 and +5
    (define player-in-room-x 0)
    (define player-in-room-y 0)
    
    ; add the initial room
    (hash-set! rooms '(ground  0  0) (get-room 'outside))
    
    ; handle key presses
    (define/override (update key-event)
      ; allow bailing out early
      (call/cc 
       (lambda (return)
         ; pull out the key code
         (define code (send key-event get-key-code))
         
         ; get the new position
         (define new-player-in-room-y
           (case code
             [(up #\w numpad7 numpad8 numpad9) (+ player-in-room-y 1)]
             [(down #\s numpad1 numpad2 numpad3) (- player-in-room-y 1)]
             [else player-in-room-y]))
         (define new-player-in-room-x
           (case code
             [(left #\a numpad1 numpad4 numpad7) (+ player-in-room-x 1)]
             [(right #\d numpad3 numpad6 numpad9) (- player-in-room-x 1)]
             [else player-in-room-x]))
         
         ; if we don't move, don't bother checking the rest
         (when (and (= player-in-room-x new-player-in-room-x)
                    (= player-in-room-y new-player-in-room-y))
           (return this))
         
         ; check if we're in a border
         (cond 
           ; border
           [(or (= 5 (abs new-player-in-room-x))
                (= 5 (abs new-player-in-room-y)))
            (define room (hash-ref rooms (list player-floor player-room-x player-room-y) #f))
            (unless (or (and (<= -1 new-player-in-room-x 1)
                             (= 5 new-player-in-room-y)
                             (send room has-door? 'north))
                        (and (<= -1 new-player-in-room-x 1)
                             (= -5 new-player-in-room-y)
                             (send room has-door? 'south))
                        (and (<= -1 new-player-in-room-y 1)
                             (= 5 new-player-in-room-x)
                             (send room has-door? 'west))
                        (and (<= -1 new-player-in-room-y 1)
                             (= -5 new-player-in-room-x)
                             (send room has-door? 'east)))
              (return this))]
           ; not a border
           [else
            ; check that it's walkable
            (define room (hash-ref rooms (list player-floor player-room-x player-room-y) #f))
            (define tile (send room get-tile 
                               (+ (- new-player-in-room-x) 4)
                               (+ (- new-player-in-room-y) 4)))
            (unless (send tile walkable?)
              (return this))
            
            ; trigger on-walk events
            (unless (send tile do-walk player tile)
              (return (if (send player dead?)
                          (new loss-screen%)
                          this)))])
         
         ; update the player position
         (set! player-in-room-x new-player-in-room-x)
         (set! player-in-room-y new-player-in-room-y)
         
         ; potentially change the room
         (cond
           [(< player-in-room-x -4)
            (set! player-in-room-x 5)
            (++! player-room-x)]
           [(> player-in-room-x 4)
            (set! player-in-room-x -5)
            (--! player-room-x)]
           [(< player-in-room-y -4)
            (set! player-in-room-y 5)
            (++! player-room-y)]
           [(> player-in-room-y 4)
            (set! player-in-room-y -5)
            (--! player-room-y)])
         
         ; generate a new room if necessary
         (unless (hash-ref rooms (list player-floor player-room-x player-room-y) #f)
           ; TODO: generate this
           (define new-room (get-room 'catacombs))
           
           
           ; add the new room to the map
           (hash-set! rooms 
                      (list player-floor player-room-x player-room-y)
                      new-room))
         
         ; return this screen again
         (if (send player dead?)
             (new loss-screen%)
             this))))
      
    ; draw the current world
    (define/override (draw canvas)
      (send canvas clear)
      
      ; get the canvas size
      (define wide (send canvas get-tiles-wide))
      (define high (send canvas get-tiles-high))
      
      ; function to draw a single room
      ; screen-x/y - screen coordinates of the center of the room
      ; room-x/y - room coordinates for the room to draw
      (define drawn-rooms (make-hash))
      (define (draw-room screen-x screen-y room-x room-y)
        ; check if we've already drawn this room
        (unless (hash-ref drawn-rooms (list room-x room-y) #f)
          ; make sure that we're still on the screen
          (when (and (<= -10 screen-x (+ wide 10))
                     (<= -10 screen-y (+ high 10)))
            ; get the room we're trying to draw
            (define room (hash-ref rooms (list player-floor room-x room-y) #f))
            (when room
              ; draw the room's tiles
              (for* ([xi (in-range 9)]
                     [yi (in-range 9)])
                (define tile (send room get-tile xi yi))
                (send canvas draw-tile 
                      (+ screen-x xi -4 player-in-room-x)
                      (+ screen-y yi -4 player-in-room-y)
                      (send tile get-tile) ; TODO: rotated?
                      (send tile get-foreground)
                      (send tile get-background)))
              
              ; --- draw the borders ---
              
              ; get the color for walls vs doors
              (define (wall-color dir i)
                (if (and (send room has-door? dir)
                         (<= 4 i 6))
                    "brown"
                    "gray"))
                
              ; the special outside square only has a north wall
              (define outside? (equal? (send room get-name) "outside"))
              
              ; actually do the drawing
              (for ([bi (in-range 11)])
                ; these all change in sync, so only four iterations
                (for ([dir  '(north south west east)]
                      [xmin '(   -5    -5   -5    5)]
                      [ymin '(   -5     5   -5   -5)]
                      [xd   `(  ,bi   ,bi    0    0)]
                      [yd   `(    0     0  ,bi  ,bi)])
                  (when (or (eq? dir 'north) (not outside?))
                    (send canvas draw-tile
                          (+ screen-x xmin player-in-room-x xd)
                          (+ screen-y ymin player-in-room-y yd)
                          #\space
                          (wall-color dir bi)
                          (wall-color dir bi)))))

              ; recur
              ; note: set drawn-rooms to avoid drawing more than once
              (hash-set! drawn-rooms (list room-x room-y) #t)
              (draw-room screen-x (- screen-y 10) room-x (- room-y 1))
              (draw-room screen-x (+ screen-y 10) room-x (+ room-y 1))
              (draw-room (- screen-x 10) screen-y (- room-x 1) room-y)
              (draw-room (+ screen-x 10) screen-y (+ room-x 1) room-y)))))
      
      ; start the recursion at the current room
      (draw-room (quotient wide 2) (quotient high 2) player-room-x player-room-y)

      ; draw the player
      (send canvas draw-tile (quotient wide 2) (quotient high 2) #\@))
    
    (super-new)))