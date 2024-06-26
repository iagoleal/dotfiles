(local M {})
(local fmt string.format)

;;; Set a default value to a variable
(macro default-value! [variable default]
  `(set-forcibly! ,variable
                  (if (= ,variable nil)
                      ,default
                      ,variable)))
(set table.pack
  #(let [t [$...]]
     (tset t :n (select :# $...))
     t))

(set table.unpack unpack)

(fn aggregate-strings [data delimiter]
  "Turn a fennel sequence of strings into a comma-separated list."
  (match (type data)
    :string data
    :table  (table.concat data (or delimiter ","))
    _       (error "Unaccepted type.")))

;;; Require a package and pollute the global environment with it
;;; If the argument is a table, add its elements to the global environment.
;;; If the argument is a string, require the module and add its elements to the global environment.
(fn M.using [pkg-name env]
  (default-value! env (getfenv 0))
  (let [pkg (match (type pkg-name)
              :string (require pkg-name)
              :table  pkg-name)]
    (each [k v (pairs pkg)]
      (tset env k v))
    env))

(fn M.force-require [pkg-name]
  (tset package.loaded pkg-name nil)
  (require pkg-name))

(fn M.first [t]
  "First element of a list or string."
  (match (type t)
    :table  (. t 1)
    :string (t:sub 1)))

(fn M.last [t]
  "last element of a list or string."
  (match (type t)
    :table  (. t (length t))
    :string (t:sub -1)))

(fn M.sort! [t]
  "Sort a list in-place and return it."
  (table.sort t)
  t)

;; Export
M
