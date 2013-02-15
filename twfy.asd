;;;; twfy-cl.asd

(asdf:defsystem #:twfy
  :serial t
  :description "TheyWorkForYou API bindings"
  :author "James Thompson <james@jamtho.com>"
  ;; :license "Specify license here"
  :depends-on (:drakma
               :cl-json)
  :components ((:file "package")
               (:file "twfy")))

