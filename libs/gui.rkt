#lang racket

(provide
 create-gui
 flip
 clear
 draw-tile
 draw-string
 draw-centered-string)

(require  
 racket/gui
 racket/draw)

; the font to use to draw the tileset
(define font
  (make-font #:size 12
             #:family 'symbol
             #:size-in-pixels? #t))

; a GUI structure
(define-struct gui
  (tile-size
   tiles-wide
   tiles-high
   frame
   canvas
   buffer
   buffer-dc
   key-listener
   dirty)
  #:mutable)

; create a new gui
(define (create-gui 
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
  
  ; the element we actually care about
  (define game-canvas%
    (class canvas%
      (inherit get-width get-height refresh)
      
      (define/override (on-char key-event)
        (when (gui-key-listener my-gui)
          ((gui-key-listener my-gui) key-event)))
      
      (define/private (my-paint-callback self dc)
        (send dc draw-bitmap (gui-buffer my-gui) 0 0))
      
      (super-new (paint-callback (lambda (c dc) (my-paint-callback c dc))))))
  
  (define canvas
    (new game-canvas%
         [parent frame]
         [min-width target-width]
         [min-height target-height]))

    #|
  (define canvas
    (new canvas% 
         [parent frame]
         [min-width target-width]
         [min-height target-height]
         [paint-callback
          (lambda (canvas dc)
            (send dc draw-bitmap (gui-buffer my-gui) 0 0))]))
|#  

  ; resize the container to actually fit the interface
  ; stupid title bar...
  (send frame show #t)
  
  ; create the offscreen buffer
  (define buffer (make-screen-bitmap target-width target-height))
  (define buffer-dc (new bitmap-dc% [bitmap buffer]))
  
  ; clear and return the gui
  (define my-gui 
    (gui tile-size 
         tiles-wide
         tiles-high 
         frame 
         canvas 
         buffer 
         buffer-dc 
         key-listener
         #t))
  
  (clear my-gui "black")
  (flip my-gui)
  
  my-gui)

; flip the buffer
(define (flip gui)
  (when (gui-dirty gui)
    (send (gui-frame gui) refresh)
    (set-gui-dirty! gui #f)))
  
; clear (a section of) the screen
(define clear
  (case-lambda
    [(gui)
     (clear gui 0 0 (gui-tiles-wide gui) (gui-tiles-high gui) "black")]
    [(gui bg)
     (clear gui 0 0 (gui-tiles-wide gui) (gui-tiles-high gui) bg)]
    [(gui x y width height)
     (clear gui x y width height "black")]
    [(gui x y width height bg)
     (set-gui-dirty! gui #t)
     (define dc (gui-buffer-dc gui))
     (define tile-size (gui-tile-size gui))
     
     (send dc set-brush (new brush% [color bg]))
     (send dc draw-rectangle
           (* tile-size x)
           (* tile-size y)
           (* tile-size width)
           (* tile-size height))]))

; draw a tile
(define (draw-tile gui x y tile [fg "white"] [bg "black"])
  (set-gui-dirty! gui #t)
  (define dc (gui-buffer-dc gui))
  (define tile-size (gui-tile-size gui))
  
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
(define (draw-string gui x y str [fg "white"] [bg "black"])
  (for ([i (in-naturals)]
        [c (in-string str)])
    (draw-tile gui (+ x i) y c fg bg)))

; draw a centered string
(define (draw-centered-string gui y str [fg "white"] [bg "black"])
  (define x (inexact->exact 
             (floor
              (- (/ (gui-tiles-wide gui) 2)
                 (/ (string-length str) 2)))))
  (draw-string gui x y str fg bg))