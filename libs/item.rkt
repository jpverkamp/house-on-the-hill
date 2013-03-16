#lang racket

(provide define-item
         random-item)

; all items and a shuffled list that will reset when empty
(define items '())
(define remaining-items '())

; represent items in the game
(define item%
  (class object%
    (init-field name
                text
                on-gain
                on-loss)
    
    (define/public (get-name) name)
    (define/public (get-text) text)
    (define/public (do-gain player) (on-gain player))
    (define/public (do-loss player) (on-loss player))
    
    (super-new)))

(define (add-item item) (set! items (cons item items)))

; define a new item
(define-syntax-rule (define-item args ...)
  (add-item (new item% args ...)))

; copy a list
(define (list-copy ls) (foldr cons '() ls))

; choose a random item, don't repeat until all have been chosen
(define (random-item)
  (when (null? remaining-items)
    (set! remaining-items (shuffle items)))
  (let ([item (car remaining-items)])
    (set! remaining-items (cdr remaining-items))
    item))