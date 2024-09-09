(local M {})
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

;; Set a keymap on global scope.
(set M.keymap vim.keymap.set)

(fn M.keymap/buffer [bufnr]
  "Create a function that sets a keymap for a specific buffer."
  (let [extra {:buffer bufnr :silent true}]
    (fn [mode keys cmd ?opts]
      (vim.keymap.set mode keys cmd (vim.tbl_extend :keep (or ?opts {}) extra)))))

;;;-------------------
;;; Vim tests
;;;-------------------
;; Here we use proper booleans, not 0~1

(fn predicate#one-to-true-based [f]
  "Convert an one based predicate (such as vim's) to a boolean based one."
  #(let [result (f $...)]
     (or (= result 1)
         (= result true))))

; Check whether this version of nvim has a certain feature
(fn M.has? [feature]
  "Fennel version of vimscript `has`"
  ((predicate#one-to-true-based vim.fn.has) feature))

(fn M.executable-exists? [name]
  "Fennel version of vimscript `executable`"
  (let [test (predicate#one-to-true-based vim.fn.executable)]
    (test name)))

(fn M.directory? [name]
  "Fennel version of vimscript `isdirectory`"
  (let [test (predicate#one-to-true-based vim.fn.isdirectory)]
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

(fn M.highlight [name keys/values]
  "Setup a highlight group."
  (vim.api.nvim_set_hl 0 name keys/values))

(fn M.hi-link [from link default]
  "Link two highlight groups."
  (vim.api.nvim_set_hl 0 from {: link : default}))

;-----------------------------
; Easier nvim internals
;-----------------------------

"Allow accessing vim.api functions with a more fennelish syntax.
 With this function, you can write, for example,

     api.set-hl

 and the call is automatically converted to `vim.api.nvim_set_hl`."
(set M.api
  (setmetatable {}
    {:__index (fn [_ key]
                (. vim.api (.. "nvim_" (string.gsub key "%-" "%_"))))}))

;-----------------------------
; Goodies
;-----------------------------

(fn M.current-word []
  "The word under the cursor."
  (vim.fn.expand "<cword>"))

(fn M.current-line []
  "The line under the cursor."
  (vim.api.nvim_get_current_line))

(fn M.pumvisible? []
  "Is the popup menu open?"
  (not= (tonumber (vim.fn.pumvisible)) 0))

(fn M.feedkeys [keys ?mode]
  "Input keys as if typed."
  (default-value! ?mode :n)
  (vim.api.nvim_feedkeys (vim.api.nvim_replace_termcodes keys true false true)
                         ?mode
                         true))

M
