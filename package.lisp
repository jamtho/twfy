;;;; package.lisp

(defpackage #:twfy
  (:use #:cl)
  (:export
   ;;; Required setting
   #:*api-key*
   
   ;;; Optional setings
   #:*output-format*
   #:*decode-response*

   ;;; API functions
   #:convert-url
   
   #:get-constituency
   #:get-constituencies
   
   #:get-person
   #:get-mp
   #:get-mp-info
   #:get-mps
   #:get-mps-info
   #:get-lord
   #:get-lords
   #:get-mla
   #:get-mlas
   #:get-msp
   #:get-msps
   
   #:get-geometry
   #:get-boundary
   
   #:get-committee
   #:get-debates
   #:get-wrans
   #:get-wms
   #:get-hansard
   
   #:get-comments))


