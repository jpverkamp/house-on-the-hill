#lang racket

(provide roll)

(define (roll dice)
  (for/sum ([i (in-range dice)])
    (quotient (random 6) 2)))