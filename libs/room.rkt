#lang racket

(provide 
 define-room
 get-room
 random-room)

(require 
 "tile.rkt")

; room definitions
(define *global-rooms* (make-hasheq))
(for ([key (in-list '(all basement ground upstairs))])
  (hash-set! *global-rooms* key (make-hasheq)))

; store information about rooms
; 
; required fields:
; name - the name for the room displayed to the room
; floorplan - the floorplan of the room, a 81 character string of tile key characters (see tile%)
; 
; optional fields
; description - a description shown to the player on entering the room
; floors - the floors that the room can appear on (default = all of them)
; doors - the directions doors are in in the default orientation (default = all of them)
; tiles - a hashmap or associative list of tile key characters to tile definitions for just this room
(define room%
  (class object%
    ; required fields
    (init-field
     name
     floorplan)
    
    ; optional fields
    (init-field
     [description ""]
     [floors '(basement ground upstairs)]
     [doors '(north south east west)]
     [tiles '()])
    
    ; accessors for public fields
    (define/public (get-name) name)
    (define/public (get-description) description)
    
    ; various helper methods
    (define/public (on-floor? floor) (and (member floor floors) #t))
    (define/public (has-door? door) (and (member door doors) #t))
    
    ; get the tile at a given (internal) location
    (define/public (get-tile x y)
      (unless (and (<= 0 x 8) (<= 0 y 8))
        (error 'get-tile "tile coordinate out of range at (~a, ~a)" x y))
      
      (define tile-char (string-ref floorplan (+ (* y 9) x)))
      (cond
        [(hash-has-key? tiles tile-char)
         (hash-ref tiles tile-char #f)]
        [(get-global-tile tile-char)
         => (lambda (tile) tile)]
        [else
         (error 'get-tile "tile '~a' not defined at (~a, ~a)" tile-char x y)]))

    ; flatten the floorplan string if given as a list of strings
    (when (list? floorplan)
      (set! floorplan (apply string-append floorplan)))
    
    ; convert the tiles to a hashmap if it isn't already
    (when (not (hash? tiles))
      (set! tiles (make-hasheq 
                   (map (lambda (tile) 
                          (cons (send tile get-tile-key) tile)) 
                        tiles))))
    
    (printf "tiles has keys: ~s\n" (hash-keys tiles))
    
    ; this has to be here
    (super-new)))

; define a room, adding it to the global collection of rooms
(define-syntax-rule (define-room args ...)
  (begin
    (define room (new room% args ...))
    (define name (string->symbol (send room get-name)))
    
    (hash-set! (hash-ref *global-rooms* 'all) name room)
    (for ([floor (in-list ((class-field-accessor room% floors) room))])
      (hash-set! (hash-ref *global-rooms* floor) name room))))

; get a single room by name
(define (get-room name)
  (hash-ref (hash-ref *global-rooms* 'all) (if (string? name) (symbol->string name) name)))

; get a random room from the given floor (or 'all to choose from all rooms)
(define (random-room [floor 'all])
  (define room-keys (hash-keys (hash-ref *global-rooms* floor)))
  (hash-ref (hash-ref *global-rooms* floor) (list-ref room-keys (random (length room-keys)))))

