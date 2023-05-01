(import-macros {: keymap : global-fn : def-command} :macros)

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
         :close   [":}" ""]}
      :ghci-par
        {:command ["ghci" "+RTS" "-N" "-RTS"]
         :open    ":{"
         :close   [":}" ""]}
      :cabal
        {:command ["cabal" "repl"]
         :open    ":{"
         :close   [":}" ""]}}
   :lhaskell
     {:ghci
        {:command ["ghci"]
         :open    ":{"
         :close   [":}" ""]}}
   :idris2
     {:idris2
        {:command ["idris2"]}}
   :julia
     {:julia
        {:command ["julia"]}
      :projectwise
        {:command ["julia" "--project=@."]}
      :lts
        {:command ["julia" "+lts" "--project=@."]}}
   :scheme
     {:chez
        {:command ["scheme"]}
      :racket
        {:command ["racket" "-il" "scheme"]}}})

(iron.core.set_config
   {:preferred {:lua     "lua"
                :fennel  "fennel"
                :haskell "ghci-par"
                :julia   "projectwise"
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
  (let [window (vim.fn.bufwinnr bufid)]
    (if (= window -1)
        (values (vim.fn.win_id2win (showfn)) true)
        (values window false))))

(fn visibility.blink [bufid showfn]
  (local (window was-hidden) (hidden bufid showfn))
  (if (not was-hidden)
      (do
        (vim.cmd.wincmd {:args ["c"] :count window})
        (let [repl-winnr (vim.fn.win_id2win (showfn))]
          (vim.cmd.wincmd {:args ["p"] :count repl-winnr})))
      (vim.cmd.wincmd {:args ["p"] :count window})))

(global-fn iron-split-open [orientation]
  (let [old-config iron.config.repl_open_cmd]
    (if (= old-config orientation)
        (iron.core.repl_for vim.bo.filetype)
        (let [old-visibility iron.config.visibility]
          (iron.core.set_config {:repl_open_cmd orientation}
                                :visibility visibility.blink)
          (iron.core.repl_for vim.bo.filetype)
          (iron.core.set_config {:visibility old-visibility})))))

;---------------------
;;; Editor Commands
;---------------------

(def-command :IronSetPreferred
  #(iron-set-preferred (unpack $1.fargs))
  :nargs :?)

;---------------------
;; Mappings
;---------------------
;; REPL
(keymap :n "<leader>it"       "<Plug>(iron-send-motion)"   {:remap true})
(keymap :v "<leader>i<Space>" "<Plug>(iron-visual-send)"   {:remap true})
(keymap :n "<leader>i."       "<Plug>(iron-repeat-cmd)"    {:remap true})
(keymap :n "<leader>i<Space>" "<Plug>(iron-send-line)"     {:remap true})
(keymap :n "<leader>ii"       "<Plug>(iron-send-line)"     {:remap true})
(keymap :n "<leader>i<CR>"    "<Plug>(iron-cr)"            {:remap true})
(keymap :n "<leader>ic"       "<Plug>(iron-interrupt)"     {:remap true})
(keymap :n "<leader>iq"       "<Plug>(iron-exit)"          {:remap true})
(keymap :n "<leader>il"       "<Plug>(iron-clear)"         {:remap true})
(keymap :n "<leader>ip"       "<Plug>(iron-send-motion)ip" {:remap true})
(keymap :n "<leader>ir"       ":IronRestart<CR>")

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
