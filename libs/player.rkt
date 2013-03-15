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