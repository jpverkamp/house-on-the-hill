(define-item
  [name "Book"]
  [text "A diary or lab notes? 
Ancient script or modern ravings?"]
  [on-gain
   (lambda (player)
     (send player stat+= 'intellect 2))]
  [on-loss
   (lambda (player)
     (send player stat-= 'intellect 2))])