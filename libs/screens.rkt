#lang racket

(provide 
 screen%
 main-menu-screen%
 game-screen%)

(require
 racket/gui
 racket/draw)

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
    (define/override (update key-event)
      (printf "you win!\n"))
    
    (define/override (draw canvas)
      (send canvas clear)
      (send canvas draw-centered-string 10 "You win!"))
    
    (super-new)))