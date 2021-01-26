;;;; cl-getpass.asd

(asdf:defsystem #:cl-getpass
  :description "Get secret strings from POSIX terminals"
  :author "Ryan Gannon (IAmRasputin) <ryanmgannon@gmail.com>"
  :license  "MIT"
  :version "0.0.1"
  :serial t
  :components ((:file "package")
               (:file "cl-getpass")))
