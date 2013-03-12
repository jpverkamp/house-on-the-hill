#lang racket

(provide 
 define-room 
 get-display
 random-room
 *rooms*)

(require 
 "color.rkt" 
 "entity.rkt"
 "tile.rkt")

; a global hash of all defined rooms
(define *rooms* (make-hasheq))
(for ([key (in-list '(all basement ground upstairs))])
  (hash-set! *rooms* key (make-hasheq)))

; a room in the mansion
(define-struct room
  (name         ; the name as displayed to the player
   description  ; the description printed to the player
   floors       ; which floors the room can appear on
   doors        ; which sides of the room have doors
   floorplan    ; the floorplan of the room (a 81 tile string, row by row)
   tiles)       ; a hash of tile character to definition
  #:transparent
  #:mutable)

; create a room
(define (define-room
          #:name name
          #:description [desc ""]
          #:floors      [floors '()]
          #:doors       [doors '()]
          #:floorplan   [floorplan (make-string 81 #\§)]
          #:tiles       [tiles (make-hasheq `((#\§ ,*default-tile*)))])
  
  ; create a default room
  (define new-room
    (room name
          desc
          floors
          doors
          (cond
            [(string? floorplan) floorplan]
            [(list? floorplan) (apply string-append floorplan)])
          (cond
            [(hash? tiles) tiles]
            [(list? tiles) (make-hasheq (map (lambda (tile) (cons (tile-char tile) tile)) tiles))])))

  ; validate parameters
  (validate-room new-room)
  
  ; add it to the necessary hashes
  (define hash-key (string->symbol name))
  (hash-set! (hash-ref *rooms* 'all) hash-key new-room)
  (for ([floor (in-list (room-floors new-room))])
    (hash-set! (hash-ref *rooms* floor) hash-key new-room)))

; test if a room is valid
(define (validate-room room)
  ; test for invalid floors
  (for ([floor (in-list (room-floors room))])
    (unless (member floor '(basement ground upstairs))
      (error (format "invalid floor: ~a"  floor))))
  
  ; test for valid doors
  (for ([door (in-list (room-doors room))])
    (unless (member door '(north south east west))
      (error (format "invalid door: ~a" door))))
  
  ; test for a valid floorplan
  (unless (and (string? (room-floorplan room)) (= 81 (string-length (room-floorplan room))))
    (error (format "invalid floorplan: ~a" (room-floorplan room)))))

; get a character from a room
(define (get-display name x y [rotated #t])
  (define hash-key (if (symbol? name) name (string->symbol name)))
  (define room (hash-ref (hash-ref *rooms* 'all) name))
  (define tile (hash-ref (room-tiles room)
                         (string-ref (room-floorplan room)
                                     (+ (* x 9) y))))
  (list (tile-char tile rotated)
        (tile-foreground tile)
        (tile-background tile)))

; select a random room from the given floor
(define (random-room [which 'all])
  (define floor (hash-ref *rooms* which))
  (define keys (hash-keys floor))
  (hash-ref floor (list-ref keys (random (length keys)))))