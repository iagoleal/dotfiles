(local gs (require :gitsigns))
(local {: sort!} (require :core))
(local {: keymap/buffer : autocmd}  (require :editor))

;; My Dotfiles worktree
(local dotfiles-worktree {:toplevel vim.env.HOME
                          :gitdir   (.. vim.env.HOME "/.local/share/dotfiles-gitdir")})

(local sign-bar "▌")

; get_actions()
(fn git-action []
  (let [actions (gs.get_actions)
        keys    (sort! (vim.tbl_keys actions))]
    (vim.ui.select
      keys
      {:prompt "Git Actions:"
       :format_item (fn [item]
                     (.. (: (item:sub 1 1) :upper)
                         (: (item:gsub "_" " ") :sub 2)))}
      (fn [choice]
        (when choice
          ((. actions choice)))))))


(fn on-attach [bufnr]
  (let [bmap (keymap/buffer bufnr)]
    ;; Menu
    (bmap :n "<leader>cg" git-action)
    ;; Blaming
    (bmap :n "<leader>gb" #(gs.blame_line {:full true}))
    ;; Hunks
    (bmap :n "<leader>gq" #(gs.setqflist :all))    ; Quickfix for entire repository
    (bmap :n "<leader>gl" #(gs.setloclist 0 0))    ; Location list for only current buffer
    (bmap :n "[c" #(if vim.wo.diff
                     (vim.cmd.normal "[c")
                     (gs.nav_hunk :prev))
      {:desc "Go to previous git hunk"})
    (bmap :n "]c" #(if vim.wo.diff
                     (vim.cmd.normal "]c")
                     (gs.nav_hunk :next))
      {:desc "Go to next git hunk"})))


(gs.setup
  {:sign_priority 1
   :worktrees     [dotfiles-worktree]
   :on_attach     on-attach})
