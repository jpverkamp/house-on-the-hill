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

; a tile for errors
(define *error-tile*
  (define-tile
    [tile "§"]
    [name "ERROR"]
    [description "Don't panic!"]
    [foreground "pink"]))

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
     [tiles '()]
     [on-enter #f])
    
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
         *error-tile*]))
         
    ; flatten the floorplan string if given as a list of strings
    (when (list? floorplan)
      (set! floorplan (apply string-append floorplan)))
    
    ; convert the tiles to a hashmap if it isn't already
    (when (not (hash? tiles))
      (set! tiles (make-hasheq 
                   (map (lambda (tile) 
                          (cons (send tile get-tile-key) tile)) 
                        tiles))))
    
    ; event for when the player enters a room
    (define/public (do-enter player)
      (when on-enter
        (on-enter player)))
    
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
; if has-doors is non-#f, rooms must have those doors
; if non-doors is non-#f, rooms must not have those doors
(define (random-room [floor 'all] [has-doors #f] [non-doors #f])
  (define room-keys (hash-keys (hash-ref *global-rooms* floor)))
  
  ; keep going until we find a room that fits
  (let loop ([tries 0])
    ; TODO: debug messages
    (when (>= tries 10)
      (printf "failed to generate a room after ~a tries...\n" tries))
    (when (>= tries 20)
      (exit))
    
    ; choose a room at random
    (define room 
      (hash-ref (hash-ref *global-rooms* floor) 
                (list-ref room-keys (random (length room-keys)))
                #f))
    
    ; if we find a room, check the doors (both required and required not)
    (if (and room
             (or (not has-doors)
                 (andmap (lambda (door) (send room has-door? door)) has-doors))
             (or (not non-doors)
                 (andmap (lambda (door) (not (send room has-door? door))) non-doors)))
        room
        (loop (+ tries 1)))))

