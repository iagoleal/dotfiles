(local {: keymap} (require :editor))

(local md (require :ft.markdown))

;; Map these to keybindings
(keymap :n "<leader>h1" #(md.to-setext-header 1))
(keymap :n "<leader>h2" #(md.to-setext-header 2))
(keymap :n "<leader>h3" #(md.to-atx-header    3))
(keymap :n "<leader>h4" #(md.to-atx-header    4))
(keymap :n "<leader>h5" #(md.to-atx-header    5))
(keymap :n "<leader>h6" #(md.to-atx-header    6))
(keymap :n "<leader>h0" md.clean-header)
(keymap :n "<leader>hd" md.clean-header)
