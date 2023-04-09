#lang racket/base

(require racket/gui/easy)

(define o (obs 1))
(obs-observe! o (lambda (v) (printf "observer a saw ~a~n" v)))
(obs-observe! o (lambda (v) (printf "observer b saw ~a~n" v)))
(obs-update! o add1)
