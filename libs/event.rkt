#lang racket

(provide define-event
         random-event)

; all events and a shuffled list that will reset when empty
(define events '())
(define remaining-events '())

; represent events in the game
(define event%
  (class object%
    (init-field name
                text
                effect)
    
    (define/public (get-name) name)
    (define/public (get-text) text)
    (define/public (do-effect player) (effect player))
    
    (super-new)))

(define (add-event event) (set! events (cons event events)))

; define a new event
(define-syntax-rule (define-event args ...)
  (add-event (new event% args ...)))

; copy a list
(define (list-copy ls) (foldr cons '() ls))

; choose a random event, don't repeat until all have been chosen
(define (random-event)
  (when (null? remaining-events)
    (set! remaining-events (shuffle events)))
  (let ([event (car remaining-events)])
    (set! remaining-events (cdr remaining-events))
    event))