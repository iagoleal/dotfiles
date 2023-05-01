(local M {})
(local fmt string.format)

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


;; Export
M
