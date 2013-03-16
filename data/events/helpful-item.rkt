(define-event
  [name "Helpful Item"]
  [text "Something stands out in this room.

Perhaps it will be useful."]
  [effect 
   (lambda (player)
     (define new-item (random-item))
     (send player say (format "You gain a ~a.\n\n~a" 
                              (send new-item get-name)
                              (send new-item get-text)))
     (send player gain-item new-item))])