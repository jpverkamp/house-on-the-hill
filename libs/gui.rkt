#lang racket

(provide make-gui)

(require  
 racket/gui
 racket/draw
 "ascii-canvas.rkt")

; a gui
(define gui%
  (class object%
    (init-field
     title
     tiles-wide
     tiles-high
     [tile-size 12]
     [key-listener #f])
    
    ; get the screen metrics
    (define target-width (* tile-size tiles-wide))
    (define target-height (* tile-size tiles-high))
    
    ; the window
    (define frame
      (new frame%
           [label title]
           [width target-width]
           [height target-height]
           [style '(no-resize-border)]))
    
    ; the canvas to draw on
    (define canvas 
      (new ascii-canvas%
           [parent frame]
           [tiles-wide tiles-wide]
           [tiles-high tiles-high]
           [tile-size tile-size]))
    
    ; resize the container to actually fit the interface
    ; stupid title bar...
    (send frame show #t)
    
    ; request focus for the canvas
    (send canvas focus)
    
    ; always need to call this
    (send canvas clear)
    (send canvas flip)
    (super-new)))
  
; create a new gui
(define-syntax-rule (make-gui args ...)
  (new gui% args ...))