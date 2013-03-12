#lang racket

(provide 
 .ask 
 .kill
 .say
 .set
 .get)

; ask the player a question, providing back the answer
(define (.ask msg)
  #f)

; kill the given entity, displaying the given message
(define (.kill who msg)
  (.say msg)
  #f)

; say the given message
(define (.say msg)
  #f)

; set a property on the given entity
(define (.set who what val)
  #f)

; get a property from the given entity (with default)
(define (.get who what def)
  #f)