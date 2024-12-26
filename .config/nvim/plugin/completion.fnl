;;; Super-tab like completion
;;; * AI helpers
;;; * Snippet expanding
;;; * LSP completion
;
; (local {: keymap
;         : feedkeys
;         : pumvisible?} (require :editor))
;
; (keymap [:i :s] "<tab>"
;   (fn []
;     (local copilot (require :copilot.suggestion))
;     (if (copilot.is_visible)                (copilot.accept)
;         (pumvisible?)                       (feedkeys "<c-n>")
;         (vim.snippet.active {:direction 1}) (vim.snippet.jump 1)
;         (feedkeys "<tab>")))
;   {:desc "Super-tab forward completion"})
;
; (keymap [:i :s] "<S-tab>"
;   (fn []
;     (if (pumvisible?)                        (feedkeys "<c-p>")
;         (vim.snippet.active {:direction -1}) (vim.snippet.jump -1)
;         (feedkeys "<S-tab>")))
;   {:desc "Super-tab backward completion"})
;
; (keymap :i "<C-n>"
;   (fn []
;     (if (pumvisible?) (feedkeys "<c-n>")
;         (next (vim.lsp.get_clients {:bufnr 0})) (vim.lsp.completion.trigger)
;         (feedkeys "<c-n>")))
;   {:desc "Trigger/select next completion"})
