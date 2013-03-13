#lang racket

(require 
 racket/path
 racket/runtime-path
 "libs/all.rkt")

; create the sandbox namespace
(define-namespace-anchor anchor)
(define ns (namespace-anchor->namespace anchor))
(current-namespace ns)

; load any extensions
(define-runtime-path data-dir "data")
(for ([path (in-directory data-dir)])
  (define ext (filename-extension path))
  (case (string->symbol (string-downcase (bytes->string/utf-8 ext)))
    [(rkt room tile entity)
     (printf "loading ~a\n" path)
     (load path)]))

; create the main gui
(define gui (create-gui "The House on the Hill" 40 24 20))
(clear gui)
(for* ([x (in-range 40)]
       [y (in-range 24)])
  (draw-tile gui x y (string-ref (number->string (remainder (+ x y) 10)) 0)))
(draw-centered-string gui 10 " The House on the Hill ")
(flip gui)

; main game thread
(thread
 (lambda ()
   (let loop ()
     (draw-tile gui (random 40) (random 24) (integer->char (+ 65 (random 26))))
     (sleep 0.1)
     (loop))))

; refresh thread
(thread
 (lambda ()
   (let loop ()
     (flip gui)
     (sleep (/ 1 30))
     (loop))))