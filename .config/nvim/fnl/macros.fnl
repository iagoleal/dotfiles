(local M {})

;;; Set a default value to a variable
(macro default-value [variable default]
  `(set-forcibly! ,variable
                  (if (= ,variable nil)
                      ,default
                      ,variable)))

;;; Setting options
(fn normal-option [name value]
  (default-value value true)
  `(tset vim.opt ,name ,value))

(fn method-option [cmd name value]
  (default-value value true)
  (let [opt-obj `(. vim.opt ,name)]
    `(: ,opt-obj ,cmd ,value)))

;;; Set a nvim option
(fn M.option [name cmd-or-val ...]
"Set a nvim option. Equivalent to viml 'set'."
  (if (sym? cmd-or-val)
      (method-option (tostring cmd-or-val) (tostring name) ...)
      (normal-option (tostring name) cmd-or-val)))

;;; Keymaps
(fn M.keymap [...]
  "Register a new nvim keymap."
  `((. (require "utils") :map) ,... ))

;;; Vimscript
(fn M.ex [command args]
  (let [cmd (tostring command)]
    `(vim.api.nvim_command
       (string.format "%s %s"
                      ,cmd
                      ,args))))

(fn M.viml [str]
  `(vim.api.nvim_exec ,str true))

;;; Autocommands
(fn M.augroup [name ...]
  (let [name (tostring name)]
    `(do
       (vim.api.nvim_command (.. "augroup " ,name))
       (vim.api.nvim_command "autocmd!")
       ,...
       (vim.api.nvim_command "augroup END"))))

(fn M.autocmd [event pat cmd]
 `(vim.cmd (string.format "autocmd %s %s %s" ,event ,pat ,cmd)))


;;; Access lua functions from viml

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
  (default-value _G._mapped_functions {})
  (local inter-compile-uid (_G.os.date "%s"))
  (local name (if prefix?
                (.. (tostring (gensym prefix?)) inter-compile-uid)
                (.. (tostring (gensym :pug)) inter-compile-uid)))

  `(do
     (tset _G._mapped_functions ,name ,val)
     (.. "_mapped_functions." ,name)))

;; Wrap given in v:lua x pug call
(fn M.vlua [what prefix?]
  `(.. "v:lua." ,(M.pug what prefix?) "()"))

(fn M.vlua-fmt [str f]
  `(string.format ,str ,(M.vlua f)))

;; Package manager

;;; Rewrite packer.use with a more fennelish syntax
  (fn M.packer-use [pkg ...]
  (local cfg [...])
  (local out {1 pkg})
  (assert (= 0 (math.fmod (length cfg) 2))
            "expected even number of keywords/values pairs")
  (for [i 1 (length cfg) 2]
    (tset out (. cfg i) (. cfg (+ i 1))))
  `((. (require :packer) :use) ,out))


;; export
M
