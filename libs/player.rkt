#lang racket

(provide 
 make-player)

(require 
 racket/gui)

(define player%
  (class object%
    
    ; if the player is currently dead
    (define dead #f)
    (define/public (dead?) dead)
    
    ; the player's four statistics
    (define stats (make-hasheq (list (cons 'might (+ 2 (random 4)))
                                     (cons 'vigor (+ 2 (random 4)))
                                     (cons 'intellect (+ 2 (random 4)))
                                     (cons 'sanity (+ 2 (random 4))))))
    (define/public (get-stat which) (hash-ref stats which 0))
    (define/public (set-stat! which value) (hash-set! stats which value))
    (define/public (stat+= which diff) (hash-set! stats which (+ (hash-ref stats which 0) diff))) 
    (define/public (stat-= which diff) (hash-set! stats which (- (hash-ref stats which 0) diff)))
    
    ; ask the player for input
    (define/public (ask msg)
      (eq? 'yes
           (message-box
            "Confirmation"
            (string-append msg " (y/n)")
            #f
            '(yes-no))))
    
    ; kill the player
    ; TODO: send this back instead
    (define/public (die msg)
      (say msg)
      (set! dead true))
    
    ; just say something to the player
    (define/public (say msg)
      (message-box
            "Message"
            msg
            #f
            '(ok)))
    
    ; always do this
    (super-new)))
      
(define-syntax-rule (make-player args ...)
  (new player% args ...))