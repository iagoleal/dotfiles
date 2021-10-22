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


;-----------------------------
;;; General Fennel
;-----------------------------

(fn M.global-fn [name args body]
  `(global ,name (fn ,args ,body)))

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

;;; Keymaps
(fn M.keymap [...]
 "Register a new nvim keymap."
  `((. (require "futils") :keymap) ,...))

;;; Autocommands
(fn M.augroup [name ...]
  (local cmds `(do
                (vim.cmd (.. "augroup " ,name))
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

(fn M.def-command [name args ...]
  ;; Begin with some checks
  (when (not (sym? name))
    (error "Name of command must be a symbol!"))
  (when (not (sequence? args))
    (error "Commands need a sequence of arguments!"))
  (let [fnl-func `(fn ,args ,...) ; Generate a function from macro's body
        nargs    (build-nargs args)
        arg-pass (build-passing-style nargs)
        command-ex (string.format "command -nargs=%s %s lua %%s(%s)"
                                  nargs
                                  (tostring name)
                                  arg-pass)]

    `(let [cmd# ((. (require :futils) :save-function-as-global) ,fnl-func)
           exstring# (string.format ,command-ex cmd#)]
       (vim.cmd exstring#))))

;;; Vimscript
(fn M.ex [command args]
  (let [cmd (tostring command)]
    `(vim.api.nvim_command
       (string.format "%s %s"
                      ,cmd
                      ,args))))

(fn M.viml [str]
  `(vim.api.nvim_exec ,str true))

;-----------------------------------
;;; Access lua functions from viml
;-----------------------------------

;; Put Unique Global
;;
;; (val :any prefix? :string) -> (uuid :string)
;;
;; Takes any given value, generates a unique name (with optional prefix)
;; and inserts value into _G. Returns unique name.
(fn M.pug [val prefix?]
  ;; gensym will generate a unique id across a compile pass, but hotpot may compile
  ;; files in separate passes as they are modified, so symbols may collide
  ;; you can avoid this by passing a unique prefix per-file or using something
  ;; like the "uid" below, based on compile time
  (default-value! _G._mapped_functions {})
  (local inter-compile-uid (_G.os.date "%s"))
  (local name (if prefix?
                (.. (tostring (gensym prefix?)) inter-compile-uid)
                (.. (tostring (gensym :pug)) inter-compile-uid)))

  `(do
     (tset _G._mapped_functions ,name ,val)
     (.. "_mapped_functions." ,name)))

;;; Wrap given value in v:lua x pug call
(fn M.vlua [what prefix?]
  `(.. "v:lua." ,(M.pug what prefix?) "()"))

(fn M.vlua-fmt [str f]
  `(string.format ,str ,(M.vlua f)))

;-------------------
;; Package manager
;-------------------

(fn vararg-to-opts [...]
  (let [cfg [...]
        out {}]
    (assert (= 0 (math.fmod (length cfg) 2))
            "Expected even number of keywords/values pairs.")
    (for [i 1 (length cfg) 2]
      (tset out (. cfg i) (. cfg (+ i 1))))
    out))

;;; Rewrite packer.use with a more fennelish syntax
(fn M.packer-use [pkg ...]
  (let [opts (vararg-to-opts ...)]
    (tset opts 1 pkg)
    `((. (require :packer) :use) ,opts)))


;; export
M
