#lang racket

(require 
 racket/path
 racket/runtime-path
 "libs/gui.rkt"
 "libs/room.rkt"
 "libs/tile.rkt")

; create the sandbox namespace
(define-namespace-anchor anchor)
(define ns (namespace-anchor->namespace anchor))
(current-namespace ns)

; load any extensions
(define-runtime-path data-dir "data")
(for ([path (in-directory data-dir)])
  (define ext (filename-extension path))
  (when ext
    (case (string->symbol (string-downcase (bytes->string/utf-8 ext)))
      [(rkt room tile entity)
       (printf "loading ~a\n" path)
       (load path)])))

; function to take a single step in the simulation (on key presses)
(define (step key-event)
  (define code (send key-event get-key-code))
  (unless (or (eq? code 'release)
              (eq? code 'menu))
    (send gui clear 0 12 40 1 "black")
    (send gui draw-centered-string 12 (format " you pressed ~a " code))
    (send gui flip)))

; create the main gui
(define gui 
  (make-gui
   [title "The House on the Hill"]
   [tiles-wide 40]
   [tiles-high 24]
   [tile-size 20]
   [key-listener step]))

(send gui draw-centered-string 10 "The House on the Hill")
(send gui draw-centered-string 12 "Press any key to begin")

;(clear gui "black")
;(draw-centered-string gui 8 "----===----" "brown")
;(for ([y (in-range 9 18)])
;  (draw-centered-string gui y "..........." "green"))
;(draw-tile gui 19 12 #\@ "white")

;(draw-centered-string gui 19 "The House on the Hill lies ahead." "white")
;(draw-centered-string gui 20 "Good luck." "white")

(send gui flip)