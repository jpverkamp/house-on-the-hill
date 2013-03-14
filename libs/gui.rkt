#lang racket

(provide make-gui)

(require  
 racket/gui
 racket/draw)

; the font to use to draw the tileset
(define font
  (make-font #:size 12
             #:family 'symbol
             #:size-in-pixels? #t))

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
    (define canvase
      (new (class canvas%
             (inherit get-width get-height refresh)
             
             (define/override (on-char key-event)
               (when key-listener
                 (key-listener key-event)))
             
             (define/private (my-paint-callback self dc)
               (send dc draw-bitmap buffer 0 0))
             
             (super-new (paint-callback (lambda (c dc) (my-paint-callback c dc)))))
           
           [parent frame]
           [min-width target-width]
           [min-height target-height]))
    
    ; resize the container to actually fit the interface
    ; stupid title bar...
    (send frame show #t)
    
    ; create the offscreen buffer
    (define buffer (make-screen-bitmap target-width target-height))
    (define dc (new bitmap-dc% [bitmap buffer]))
        
    ; flip the buffer
    (define/public (flip)
      (send frame refresh))
      
    ; clear (a section of) the screen
    (define/public clear
      (case-lambda
        [()
         (send this clear 0 0 tiles-wide tiles-high "black")]
        [(bg)
         (send this clear 0 0 tiles-wide tiles-high bg)]
        [(x y width height)
         (send this clear x y width height "black")]
        [(x y width height bg)
         (send dc set-brush (new brush% [color bg]))
         (send dc draw-rectangle
               (* tile-size x)
               (* tile-size y)
               (* tile-size width)
               (* tile-size height))]))
      
    ; draw a single tile
    (define/public (draw-tile x y tile [fg "white"] [bg "black"])
      ; draw the background block
      (send dc set-brush (new brush% [color bg]))
      (send dc draw-rectangle 
            (* tile-size x)
            (* tile-size y) 
            tile-size 
            tile-size)
      
      ; draw the foreground tile
      (send dc set-font font)
      (send dc set-text-foreground fg)
      (send dc draw-text 
            (string tile) 
            (* tile-size x)
            (* tile-size y)))
      
    ; draw a string
    (define/public (draw-string x y str [fg "white"] [bg "black"])
      (for ([i (in-naturals)]
            [c (in-string str)])
        (draw-tile (+ x i) y c fg bg)))
      
    ; draw a centered string
    (define/public (draw-centered-string y str [fg "white"] [bg "black"])
      (define x (inexact->exact 
                 (floor
                  (- (/ tiles-wide 2)
                     (/ (string-length str) 2)))))
      (draw-string x y str fg bg))
    
    ; always need to call this
    (send this clear)
    (send this flip)
    (super-new)))
  
; create a new gui
(define-syntax-rule (make-gui args ...)
  (new gui% args ...))