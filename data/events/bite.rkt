(define-event
  [name "Bite"]
  [text "A growl, the scent of darkness.
Pain. Darkness. Gone."]
  [effect
   (lambda (player)
     (define player-roll (roll (send player get-stat 'might)))
     (define bite-roll (roll 4))
     (cond
       [(and (< player-roll bite-roll) (zero? (random 2)))
        (send player say "The bite tears at your flesh. You feel weaker.")
        (send player stat-= 'might 1)]
       [(< player-roll bite-roll)
        (send player say "The bite stings. Is that normal?\nSuddenly you feel tired.")
        (send player stat-= 'vigor 1)]
       [else
        (send player say "The bite hardly seems worth mentioning.\nYou shrug it off.")]))])