#lang racket/base

(require racket/gui/easy racket/gui/easy/operator)

(define @o (@ 1))
(obs-observe! @o
              (λ (x) (printf "observer a saw ~a\n" x)))
(obs-observe! @o
              (λ (x) (printf "observer b saw ~a\n" x)))
(<~ @o add1)
