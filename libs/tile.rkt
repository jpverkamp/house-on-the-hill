#lang racket

(provide 
 define-tile
 tile-name
 tile-description
 tile-char
 tile-foreground
 tile-background
 *default-tile*)

(require 
 "color.rkt"
 "entity.rkt")

; a displayable world tile
(define-struct tile 
  (name         ; the name displayed to the player
   description  ; the description printed for the player
   default-char ; the default (non-rotated) character to display
   rotated-char ; the character to display when rotated 90 degrees
   foreground   ; the foreground color to draw with
   background   ; the background color to draw with
   walkable     ; if we can walk on the tile
   events       ; any event handlers this event has
   )
  #:transparent)

; accessor for char, normal or rotated
(define (tile-char tile [rotated #f])
  ((if rotated tile-rotated-char tile-default-char ) tile))

; a default event that does nothing
(define *default-event*
  (lambda (player tile)
    #t))

; create a new tile
(define (define-tile
          #:tile char
          #:rotatedTile [rotated-char char]
          #:name name
          #:description [desc ""]
          #:foreground [fg white]
          #:background [bg black]
          #:walkable [walkable #t]
          #:onWalk [event:onWalk *default-event*])
  
  ; create the tile
  (define new-tile
    (tile name
          desc
          char
          rotated-char
          fg
          bg
          walkable
          (make-hasheq
           `((on-walk ,event:onWalk)))))
  
  ; return it
  new-tile)

; a default tile for error handling
(define *default-tile*
  (define-tile
    #:tile #\§
    #:name "ERR"
    #:description "Don't panic!"
    #:walkable #t
    #:onWalk (lambda (player tile)
               (.kill player "Panic!"))))