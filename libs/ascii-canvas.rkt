#lang racket

(provide ascii-canvas%)

(require  
 racket/gui
 racket/draw
 "screens.rkt")

; an ascii only canvas
(define ascii-canvas%
  (class canvas%
    (inherit 
      get-width
      get-height
      refresh)
    
    (init-field
     parent
     tiles-wide
     tiles-high
     tile-size)
    
    ; simple accessor
    (define/public (get-tiles-wide) tiles-wide)
    (define/public (get-tiles-high) tiles-high)
    
    ; the font to use to draw the tileset
    (define font
      (make-font 
       #:size tile-size
       #:family 'symbol
       #:size-in-pixels? #t))
    
    ; get the screen metrics
    (define target-width (* tile-size tiles-wide))
    (define target-height (* tile-size tiles-high))
    
    ; define the current active screen
    (define active-screen
      (new main-menu-screen%))
    
    ; process keyboard events  
    (define/override (on-char key-event)
      (unless (eq? 'release (send key-event get-key-code))
        (set! active-screen (send active-screen update key-event))
        (printf "current screen: ~s\n" active-screen)
        (cond
          [(is-a? active-screen screen%)
           (flip)]
          [else
           (exit)])))
  
    ; repaint the canvas
    (define/private (my-paint-callback self dc)
      (send active-screen draw this)
      (send dc draw-bitmap buffer 0 0))
    
    ; create the offscreen buffer
    (define buffer (make-screen-bitmap target-width target-height))
    (define dc (new bitmap-dc% [bitmap buffer]))
    
    ; flip the buffer
    (define/public (flip)
      (send parent refresh))
    
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
    
    (super-new 
     [parent parent]
     [paint-callback (lambda (c dc) (my-paint-callback c dc))]
     [min-width target-width]
     [min-height target-height])))