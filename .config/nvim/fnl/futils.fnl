(local M {})
(local utils (require :utils))
(local fmt string.format)

(fn table.pack [...]
  (let [t [...]]
    (tset t :n (select :# ...))
    t))

(set table.unpack unpack)

;;; Set a default value to a variable
(macro default-value! [variable default]
  `(set-forcibly! ,variable
                  (if (= ,variable nil)
                      ,default
                      ,variable)))

(fn aggregate-strings [data delimiter]
  "Turn a fennel sequence of strings into a comman-separated list."
  (match (type data)
    :string data
    :table  (table.concat data (or delimiter ","))
    _       (error "Unaccepted type.")))

;;; Convert an alternating sequence of keys/values into a table.
(fn paired-sequence-to-table [t]
  (local out {})
  (assert (= 0 (math.fmod (length t) 2))
          "Expected even number of keywords/values pairs.")
  (for [i 1 (length t) 2]
    (let [key   (. t i)
          value (. t (+ i 1))]
      (tset out key value)))
  out)

(fn callable? [f]
  "Test whether its argument is callable."
  (match (type f)
    :function true
    :table    (let [mt (getmetatable f)]
                (and mt mt.__call))
    _         false))

;;; Require a package and pollute the global environment with it
;;; If the argument is a table, add its elements to the global environment.
;;; If the argument is a string, require the module and add its elements to the global environment.
(fn M.using [pkg-name env]
  (let [pkg (match (type pkg-name)
              :string (require pkgname)
              :table  pkgname)
        env (or env (getfenv 0))]
    (each [k v (pairs pkg)]
      (tset env k v))
    env))

(fn M.force-require [pkg-name]
  (tset package.loaded pkg-name nil)
  (require pkg-name))

;----------------------------
; Autocommands
;----------------------------

(fn save-function-as-global [f]
  (default-value! _G._mapped_functions {})
  (let [memo _G._mapped_functions]
    (table.insert memo f)
    (let [f-index (length memo)]
      (string.format "_G['_mapped_functions'][%d]" f-index))))
(tset M :save-function-as-global save-function-as-global)

(fn process-rhs/autocmd [cmd]
  (match (type cmd)
    :string cmd
    (where _ (callable? cmd)) (fmt "lua %s()" (save-function-as-global cmd))
    _       (error "Only strings, functions or callable table may be mapped.")))

(fn M.autocmd [event pat cmd]
  (let [event (aggregate-strings event)
        pat   (aggregate-strings pat)
        cmd   (process-rhs/autocmd cmd)]
    (vim.cmd (string.format "autocmd %s %s %s" event pat cmd))))

;-------------------
; Keymaps
;-------------------

(fn process-rhs/keymap [cmd]
  (match (type cmd)
    :string cmd
    (where _ (callable? cmd)) (fmt "<cmd>lua %s()<CR>"
                                   (save-function-as-global cmd))
    _       (error "Only strings, functions or callable table may be mapped.")))


(fn M.keymap [mode keys cmd ...]
  "Set a keymap on global scope."
  (let [opts (paired-sequence-to-table [...])]
    (vim.keymap.set mode keys cmd opts)))


(fn M.keymap-buffer [buf mode keys cmd ...]
  "Set a keymap on buffer scope."
  (let [opts (paired-sequence-to-table [...])
        cmd  (process-rhs/keymap cmd)]
    ; Better to be non-recursive by default
    (default-value! opts.noremap true)
    (vim.api.nvim_buf_set_keymap buf mode keys cmd opts)))


;-------------------
; Vim tests
;-------------------

(fn predicate#one-to-true-based [f]
  "Convert an one based predicate (such as vim's) to a boolean based one."
  #(or (= (f $...) 1)
       (= (f $...) true)))

; Check whether this version of nvim has a certain feature
(fn M.has? [feature]
  ((predicate#one-to-true-based vim.fn.has) feature))

(fn M.executable-exists? [name]
  (let [test (predicate#one-to-true-based vim.fn.executable)]
    (test name)))

;-------------------
; Echo messages
;-------------------

(fn M.echohl [text hl]
  "Echo a message using a given highlight group"
  (default-value! hl "")
  (let [emsg (vim.fn.escape text "\"")]
    (vim.api.nvim_echo [[emsg hl]] false [])))

(fn M.echowarn [text]
  "Echo a message with a Warning highlight"
  (M.echohl text :WarningMsg))

(fn M.echoerror [text]
  "Echo a message with an Error highlight.
(to stdout not stderr)"
  (M.echohl text :WarningMsg))

(fn M.dump [...]
  "Pretty print information about lua objects."
  (let [input  (table.pack ...)
        output []]
    (for [i 1 input.n]
      (tset output i (vim.inspect (. input i))))
    (print (unpack output))))


;-----------------------------
; Colorscheme and highlights
;-----------------------------

(fn M.colorscheme [c]
  "Set nvim colorscheme."
  (vim.cmd (.. "colorscheme " c)))

(fn M.highlight [name ...]
  (let [keys/values (paired-sequence-to-table [...])]
    (vim.api.nvim_set_hl 0 name keys/values)))


;; Export
M
