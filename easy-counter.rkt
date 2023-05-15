#lang racket/base

(require racket/gui/easy
         racket/gui/easy/operator)
(define @count (@ 0))
(render
 (window
  #:title "Counter"
  (hpanel
   (button "-" (λ () (<~ @count sub1)))
   (text (~> @count number->string))
   (button "+" (λ () (<~ @count add1))))))
