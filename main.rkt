#lang racket

(require 
 racket/path
 racket/runtime-path
 "libs/gui.rkt"
 "libs/room.rkt"
 "libs/tile.rkt"
 "libs/event.rkt"
 "libs/item.rkt"
 "libs/dice.rkt")

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

; create the main gui
(define gui 
  (make-gui
   [title "The House on the Hill"]
   [tiles-wide 80]
   [tiles-high 48]
   [tile-size 10]))