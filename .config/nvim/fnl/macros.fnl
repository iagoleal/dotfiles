(local M {})

(local fmt string.format)

;;; Set a default value to a variable
(macro default-value! [variable default]
  `(set-forcibly! ,variable
                  (if (= ,variable nil)
                      ,default
                      ,variable)))

;; Return the type of the literal given
(fn get-literal-type [x]
  (if (sym? x)       :symbol
      (list? x)      :list
      (sequence? x)  :sequence
      (table? x)     :table
      (varg? x)      :vararg
      (multi-sym? x) :multi-sym
      (type x)))

(fn last [t]
  (. t (length t)))

(fn vararg-to-opts [...]
  (let [cfg [...]
          out {}]
    (assert (= 0 (math.fmod (length cfg) 2))
            (fmt "Expected even number of keywords/values pairs. %d given" (length cfg)))
    (for [i 1 (length cfg) 2]
      (tset out (. cfg i) (. cfg (+ i 1))))
    out))

;-----------------------------
;;; General Fennel
;-----------------------------

(fn M.global-fn [name args body]
  `(global ,name (fn ,args ,body)))

(fn M.require-use [pkg ...]
  `(. (require ,pkg) ,...))

;-----------------------------
;;; Setting options
;-----------------------------

(fn set-normal-option [name value]
  (default-value! value true)
  `(tset vim.opt ,name ,value))

(fn set-method-option [cmd name value]
  (default-value! value true)
  (let [opt-obj `(. vim.opt ,name)]
    `(: ,opt-obj ,cmd ,value)))

;;; Set a nvim option
(fn M.option [name cmd-or-val ?setting-value]
 "Set a nvim option. Equivalent to viml 'set'."
  (if (sym? cmd-or-val)
      (set-method-option (tostring cmd-or-val) name ?setting-value)
      (set-normal-option name cmd-or-val)))

;;; Keymap

(fn M.keymap [mode keys cmd ...]
  (let [opts (vararg-to-opts ...)]
    `(vim.keymap.set ,mode ,keys ,cmd ,opts)))

(fn M.highlight [group ...]
  (let [opts (vararg-to-opts ...)]
    `(vim.api.nvim_set_hl 0 ,group ,opts)))

;;; Autocommands
(fn M.augroup [name ...]
  (local opening (match (get-literal-type name)
                   :string (.. "augroup " name)
                   _       `(.. "augroup " ,name)))
  (local cmds `(do
                (vim.cmd ,opening)
                (vim.cmd "autocmd!")
                ,...))
  (table.insert cmds '(vim.cmd "augroup END"))
  cmds)

;;;
;;; Define commands
;;;


(fn has-vararg? [seq]
  (fn loop [seq idx]
    (match (get-literal-type (. seq idx))
      :nil    false
      :vararg true
      _       (loop seq (+ idx 1))))
  (loop seq 1))

(fn optional-arg? [x]
  (= (string.sub (tostring x) 1 1) "?"))

(fn build-nargs [seq]
  (match (values (length seq)
                 (has-vararg? seq)
                 (optional-arg? (. seq 1)))
    (0 _     _)     "0" ; No arguments
    (1 false true)  "?" ; Only a named argument like '?x'
    (1 false false) "1" ; Only a normal named argument
    (1 true  _)     "*" ; Only a vararg
    ;; Length greater than 1
    (_ _ true)  "*"     ; Many arguments, first is optional
    (_ _  _)    "+"))   ; Many arguments, no optional

(fn build-passing-style [narg]
  (match narg
    "0" ""
    "1" "<q-args>"
    "?" "<q-args>"
    "*" "<f-args>"
    "+" "<f-args>"))

(fn M.def-command [name f ...]
  (let [opts (vararg-to-opts ...)]
    `(vim.api.nvim_create_user_command ,name ,f ,opts)))

;;; Vimscript
(fn M.ex [command args]
  (let [cmd (tostring command)]
    `(vim.api.nvim_command
       (string.format "%s %s"
                      ,cmd
                      ,args))))

(fn M.viml [str]
  `(vim.api.nvim_exec ,str true))

;-------------------
;; Package manager
;-------------------

;;; Rewrite packer.use with a more fennelish syntax
(fn M.packer-use [pkg ...]
  (let [opts (vararg-to-opts ...)]
    (tset opts 1 pkg)
    `((. (require :packer) :use) ,opts)))

(fn M.require-setup [pkg ...]
  (let [opts (vararg-to-opts ...)]
   `((. (require ,pkg) :setup) ,opts)))


;; export
M
