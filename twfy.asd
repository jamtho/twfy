;;;; twfy.asd

(asdf:defsystem #:twfy
  :serial t
  :description "TheyWorkForYou API bindings"
  :author "James Thompson <james@jamtho.com>"
  :license "BSD-style"
  :depends-on (:drakma
               :cl-json)
  :components ((:file "package")
               (:file "twfy")))

