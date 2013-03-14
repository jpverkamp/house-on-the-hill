#lang racket

(provide 
 define-tile
 define-global-tile
 get-global-tile)

; global tiles
(define *global-tiles* (make-hasheq))

; store information about tiles
; 
; required fields:
; the name for the room displayed to the room
; the default tile to display to the player
; 
; optional fields:
; description - the description sent to the player on inspection (default = "")
; rotated-tile - the tile to use when the room is rotated 90 degrees (default = tile)
; foreground - the foreground color (default = "white")
; background - the background color (default = "black")
; walkable - if you can walk on the tile (default = #t)
; on-walk - event called when the player walks onto this tile (default = none)
(define tile%
  (class object%
    ; required fields
    (init-field
     name
     tile)
    
    ; optional fields
    (init-field
     [description ""]
     [rotated-tile tile]
     [foreground "white"]
     [background "black"]
     [walkable #t]
     [on-walk #f])
    
    ; accessors for public fields
    (define/public (get-name) name)
    (define/public (get-description) description)
    (define/public (get-foreground) foreground)
    (define/public (get-background) background)
    
    ; various helper methods
    (define/public (get-tile [rotated #f])
      (if rotated rotated-tile tile))
    (define/public (walkable?) walkable)
    
    ; fix the tiles if they were given as a string
    (when (string? tile)
      (set! tile (string-ref tile 0)))
    (when (string? rotated-tile)
      (set! tile (string-ref rotated-tile 0)))
    
    ; this has to be here
    (super-new)))

; public API for tiles
(define-syntax-rule (define-tile args ...)
  (new tile% args ...))

; public API for defining tiles
; these will be used if a room doesn't override it with define-tile
; if you call this more than once with different keys, the last will be used
; TODO: finish this
(define-syntax-rule (define-global-tile args ...)
  (begin
    (define tile (define-tile args ...))
    (define char (send tile get-tile))
    
    (hash-set! *global-tiles* char tile)))

; get a global tile definition
(define (get-global-tile char)
  (hash-ref *global-tiles* char #f))