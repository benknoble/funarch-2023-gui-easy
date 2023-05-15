#lang racket/gui/easy

(define o (@ 1))
(obs-observe! o (λ (x) (printf "a got ~a\n" x)))
(obs-observe! o (λ (x) (printf "b got ~a\n" x)))
(<~ o add1)
