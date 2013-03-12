#lang racket

(require 
 racket/path
 racket/runtime-path
 "libs/all.rkt")

; create the sandbox namespace
(define-namespace-anchor anchor)
(define ns (namespace-anchor->namespace anchor))
(current-namespace ns)

; load any extensions
(define-runtime-path data-dir "data")
(for ([path (in-directory data-dir)])
  (define ext (filename-extension path))
  (case (string->symbol (string-downcase (bytes->string/utf-8 ext)))
    [(rkt room tile entity)
     (printf "loading ~a\n" path)
     (load path)]))