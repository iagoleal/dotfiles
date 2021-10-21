(import-macros {: viml : keymap : pug : global-fn} :macros)

;--------------------------
;;;; Configure Iron REPL
;--------------------------

(local iron       (require :iron))
(local visibility (require :iron.visibility))

(iron.core.add_repl_definitions
  {:lua
     {:luajit
        {:command ["luajit"]}
      :lua51
        {:command ["lua5.1"]}
      :lua52
        {:command ["lua5.2"]}
      :lua53
        {:command ["lua5.3"]}
      :lua54
        {:command ["lua5.4"]}
      :love
        {:command ["love" "--console" "."]}}
   :fennel
     {:love
        {:command ["love" "--console" "."]}}
   :haskell
     {:stack
        {:command ["stack" "ghci"]
         :open    ":{"
         :close   [":}" ""]}}
   :scheme
     {:chez
        {:command ["scheme"]}
      :racket
        {:command ["racket" "-il" "scheme"]}}})

(iron.core.set_config
   {:preferred {:lua     "lua"
                :fennel  "fennel"
                :haskell "stack"
                :python  "python"
                :scheme  "racket"}
    :repl_open_cmd "rightbelow 66 vsplit"
    :visibility     visibility.toggle})

;----------------------
;; Utility Functions
;----------------------

;;; Set preferred repl to current buffers filetype
(global-fn iron-set-preferred [repl]
  (let [ft vim.bo.filetype]
    (when (= repl nil)
      (let [repls   (vim.tbl_map #(. $ 1)
                                 (iron.core.list_definitions_for_ft ft))
            prompts {}]
        (table.sort repls) ; Sort repls in alphabetical order
        ;; Construct the prompt for each repl
        (each [i name (ipairs repls)]
          (tset prompts i (string.format "%d. %s" i name)))
       (local choice (vim.fn.inputlist prompts))
       (set-forcibly! repl (. repls choice))))
    (iron.core.set_config {:preferred {ft repl}})))

(fn hidden [bufid showfn]
  (var was-hidden false)
  (var window (vim.fn.bufwinnr bufid))
  (when (= window -1)
    (set was-hidden true)
    (set window (vim.fn.win_id2win (showfn))))
  (values window was-hidden))

(fn visibility.blink [bufid showfn]
  (var (window was-hidden) (hidden bufid showfn))
  (if (not was-hidden)
      (do
        (vim.api.nvim_command (.. window "wincmd c"))
        (set window (vim.fn.win_id2win (showfn)))
        (vim.api.nvim_command (.. window "wincmd p")))
      (vim.api.nvim_command (.. window "wincmd p"))))

(global-fn iron-split-open [orientation]
  (let [old-config iron.config.repl_open_cmd]
    (if (= old-config orientation)
      (iron.core.repl_for (vim.api.nvim_buf_get_option 0
                                                       :filetype))
      (let [old-visibility iron.config.visibility]
        (iron.core.set_config {:repl_open_cmd orientation}
                              :visibility visibility.blink)
        (iron.core.repl_for (vim.api.nvim_buf_get_option 0
                                                         :filetype))
        (iron.core.set_config {:visibility old-visibility})))))

;---------------------
;;; Editor Commands
;---------------------

(vim.cmd (string.format "command! -nargs=? IronSetPreferred :lua %s(<f-args>)"
                        (pug iron-set-preferred)))
;---------------------
;; Mappings
;---------------------
;; REPL
(keymap :n :<leader>it       "<Plug>(iron-send-motion)"   :noremap false)
(keymap :v :<leader>i<Space> "<Plug>(iron-visual-send)"   :noremap false)
(keymap :n :<leader>i.       "<Plug>(iron-repeat-cmd)"    :noremap false)
(keymap :n :<leader>i<Space> "<Plug>(iron-send-line)"     :noremap false)
(keymap :n :<leader>ii       "<Plug>(iron-send-line)"     :noremap false)
(keymap :n :<leader>i<CR>    "<Plug>(iron-cr)"            :noremap false)
(keymap :n :<leader>ic       "<Plug>(iron-interrupt)"     :noremap false)
(keymap :n :<leader>iq       "<Plug>(iron-exit)"          :noremap false)
(keymap :n :<leader>il       "<Plug>(iron-clear)"         :noremap false)
(keymap :n :<leader>ip       "<Plug>(iron-send-motion)ip" :noremap false)
(keymap :n :<leader>ir       ":IronRestart<CR>")

;; Open REPL on bottom split
(keymap :n :<leader>is #(iron-split-open "botright   12 split"))
(keymap :n :<leader>iS #(iron-split-open "belowright 12 split"))

;; Open REPL on right split
(keymap :n :<leader>iv #(iron-split-open "botright   66 vsplit"))
(keymap :n :<leader>iV #(iron-split-open "belowright 66 vsplit"))

; Send entire file
(keymap :n :<leader>if #(let [send (. (require :iron) :core :send)]
                          (send vim.bo.filetype
                                (vim.api.nvim_buf_get_lines 0 0 -1 false))))
