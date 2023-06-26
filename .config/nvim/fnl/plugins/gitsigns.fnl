(local gs (require :gitsigns))
(local {: keymap/buffer : autocmd}  (require :editor))

;; My Dotfiles worktree
(local dotfiles-worktree {:toplevel vim.env.HOME
                          :gitdir   (.. vim.env.HOME "/.dotfiles-gitdir")})

(local sign-bar "▌")

(fn on-attach [bufnr]
  (let [bmap (keymap/buffer bufnr)]
    ;; Blaming
    (bmap :n "<leader>gb" #(gs.blame_line {:full true}))
    ;; Hunks
    (bmap :n "<leader>gq" #(gs.setqflist :all))                           ; Quickfix for entire repository
    (bmap :n "<leader>gl" #(gs.setqflist 0 {:use_location_list true}))    ; Location list for only current buffer
    (bmap :n "[c" #(if vim.wo.diff
                     (vim.cmd.normal "[c")
                     (vim.schedule gs.prev_hunk))
      {:desc "Go to previous git hunk"})
    (bmap :n "]c" #(if vim.wo.diff
                     (vim.cmd.normal "]c")
                     (vim.schedule gs.next_hunk))
      {:desc "Go to next git hunk"})))


(gs.setup
  {:sign_priority 1
   :worktrees     [dotfiles-worktree]
   :on_attach     on-attach})
