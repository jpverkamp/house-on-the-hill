(define-event
  [name "Bite"]
  [text "A growl, the scent of darkness.
Pain. Darkness. Gone.

A mysterious something comes out of the darkness and bites you."]
  [effect 
   (lambda (player)
     (define player-score (roll (send player get-stat 'might)))
     (define bite-score (roll 4))
     (cond
       [(< player-score bit-score)
        (send player say "The bite hurts.")
        (send player stat-= (if (zero? (random 2)) 'might 'vigor) 1)]
       [else
        (send player say "You manage to shrug it off.")]))])
            