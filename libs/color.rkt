#lang racket

(provide
 color
 color?
 color-ref
 
 white
 black)

; colors are RGB
(define-struct color (r g b) #:transparent)
(define (color-ref color band)
  (case band
    [(0 'red) (color-r color)]
    [(1 'green) (color-g color)]
    [(2 'blue) (color-b color)]))

; some standard colors
(define white (color 255 255 255))
(define black (color 0 0 0))