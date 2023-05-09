#lang racket

(require racket/gui/easy
         racket/gui/easy/operator)
(define @count (@ 0))
(render
  (window
    #:title "Counter"
    (hpanel
      (button "-" (λ () (<~ @count sub1)))
      (text (~> @count ~a))
      (button "+" (λ () (<~ @count add1))))))
