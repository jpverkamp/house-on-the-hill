#lang racket

(provide make-gui)

(require  
 racket/gui
 racket/draw
 "ascii-canvas/ascii-canvas.rkt"
 "screens.rkt")

; a gui
(define gui%
  (class object%
    (init-field
     title
     tiles-wide
     tiles-high)
    
    ; define the current active screen
    (define active-screen (new main-menu-screen%))
    
    ; the window
    (define frame
      (new frame%
           [label title]
           [style '(no-resize-border)]))
    
    ; the canvas to draw on
    (define canvas 
      (new (class ascii-canvas%
             (inherit-field
              width-in-characters
              height-in-characters)
             
             ; process keyboard events  
             (define/override (on-char key-event)
               (case (send key-event get-key-code)
                 [(escape) (exit)]
                 [(release menu) (void)]
                 [else
                  (set! active-screen (send active-screen update key-event))
                  (cond
                    [(is-a? active-screen screen%)
                     (send active-screen draw this)
                     (send frame refresh)]
                    [else
                     (exit)])]))
             
             (super-new 
              [parent frame]
              [width-in-characters tiles-wide]
              [height-in-characters tiles-high])
             
             )))
    
    ; resize the container to actually fit the interface
    ; stupid title bar...
    (send frame show #t)
    
    ; request focus for the canvas
    (send canvas focus)
    
    ; always need to call this
    (send canvas clear)
    (send frame refresh)
    
    (send active-screen draw canvas)
    (send frame refresh)
    
    (super-new)))
  
; create a new gui
(define-syntax-rule (make-gui args ...)
  (new gui% args ...))