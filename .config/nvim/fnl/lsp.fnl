(local lspconfig (require :lspconfig))
(local {: keymap : autocmd}  (require :futils))
(local util lspconfig.util)

(import-macros {: augroup} :macros)

(macro require-use [pkg ...]
  `(. (require ,pkg) ,...))

(fn capable? [client capability]
  (. client.server_capabilities capability))

;;; Only map keybinds after attaching LSP
(fn on-attach [client bufnr]
  (let [bmap (fn [mode keys cmd ...]
               (keymap mode keys cmd :buffer bufnr :silent true ...))]

    ; Use lsp omnifunc for completion
    (tset vim.bo bufnr :omnifunc "v:lua.vim.lsp.omnifunc")

    ;; Mappings
    (when (capable? client :hoverProvider)
      (bmap :n "K"          vim.lsp.buf.hover))
    (when (capable? client :signatureHelpProvider)
      (bmap :n "<C-k>"      vim.lsp.buf.signature_help))

    (bmap :n "gr"         vim.lsp.buf.references)
    (bmap :n "<leader>rn" vim.lsp.buf.rename)

    (bmap :n "<leader>wa" vim.lsp.buf.add_workspace_folder)
    (bmap :n "<leader>wr" vim.lsp.buf.remove_workspace_folder)
    (bmap :n "<leader>wl" #(print (vim.inspect (vim.lsp.buf.list_workspace_folders))))

    (when (capable? client :definitionProvider)
      (bmap :n "gd"         vim.lsp.buf.definition
        :desc "Go to definition"))
    (when (capable? client :typeDefinitionProvider)
      (bmap :n "<leader>D" vim.lsp.buf.type_definition
        :desc "Go to type definition"))
    (when (capable? client :declarationProvider)
      (bmap :n "gD"         vim.lsp.buf.declaration
        :desc "Go to declaration"))
    (when (capable? client :implementationProvider)
      (bmap :n "g<C-d>"     vim.lsp.buf.implementation
        :desc "Go to implementation"))

    ;; Set some keybinds conditional on server capabilities
    (bmap :n "<leader>=" #(vim.lsp.buf.format {:async true}))

    (when (capable? client :codeActionProvider)
      (bmap :n "<leader>ca" vim.lsp.buf.code_action
        :desc "Execute Code Action under cursor"))

    (when (capable? client :codeLensProvider)
      (bmap :n "<leader>cl" vim.lsp.codelens.run)
      (augroup :LspCodeLens
        (autocmd [:BufEnter :CursorHold :InsertLeave] "<buffer>" vim.lsp.codelens.refresh
          :desc "Execute Code Lens under cursor")))))


;; Diagnostics
(keymap :n "<leader>e"  vim.diagnostic.open_float
  :desc "Open diagnostics popup")
(keymap :n "[d"         vim.diagnostic.goto_prev
  :desc "Previous diagnostic")
(keymap :n "]d"         vim.diagnostic.goto_next
  :desc "Next diagnostic")
(keymap :n "<leader>dq" vim.diagnostic.setloclist
  :desc "Put diagnostics on location list")

;; Configure diagnostics (for all servers)
(vim.diagnostic.config {:virtual_text     false
                        :signs            true
                        :underline        false
                        :update_in_insert false
                        :severity_sort    true})

;;--------------------------
;; Server specific setups
;;--------------------------


;;; Lua
;; set the path to the sumneko installation;
(let [sumneko-root-path (.. (vim.fn.stdpath :data) "/lspinstall/lua/sumneko-lua")
      sumneko-binary    (.. (vim.fn.stdpath :data) "/lspinstall/lua/sumneko-lua-language-server")
      path              (vim.split package.path ";")]
  (table.insert path "lua/?.lua")
  (table.insert path "lua/?/init.lua")

  (lspconfig.sumneko_lua.setup
    {:on_attach on-attach
     :cmd [sumneko-binary "-E" (.. sumneko-root-path "/main.lua")]
     :settings
       {:Lua
         {:runtime
            {:version "LuaJIT"
             ; Setup lua path
             :path    path}
          :diagnostics {:globals [:vim :love]
                        :disable [:lowercase-global]}
          :workspace
            {:preloadFileSize 300
             :checkThirdParty false
             :library
               ;; Make the server aware of Neovim and love2d runtime files
               {(vim.fn.expand  "$VIMRUNTIME/lua")         true
                (vim.fn.stdpath :config)                   true
                (vim.fn.expand  "$VIMRUNTIME/lua/vim/lsp") true
                "${3rd}/love2d/library"                    true}
             (vim.fn.expand "~/.luarocks/share/lua/5.1") true
             "/usr/share/lua/5.1" true}
          ; Do NOT send telemetry data
          :telemetry {:enable false}}}}))


;;; Haskell
(lspconfig.hls.setup
  {:on_attach on-attach
   :root_dir (fn [fname]
               (local util lspconfig.util)
               ((util.root_pattern :*.cabal :stack.yaml :cabal.project :package.yaml :hie.yaml :*.hs) fname))
   :settings
     {:haskell
        {:plugin
          {:wingman
            {:config {:proofstate_styling true
                      :timeout_duration 5}}}}}})

;;; Julia
(lspconfig.julials.setup
  {:on_attach on-attach
   :autostart true
   :root_dir (fn [fname]
               (or ((lspconfig.util.root_pattern "Project.toml") fname)
                   (util.find_git_ancestor fname)))
   :single_file_support true
   :filetypes [:julia]})


;;; Python
(lspconfig.pyright.setup {:on_attach on-attach})

;;; C / C++
(lspconfig.ccls.setup {:on_attach on-attach})

;;; Prose
(lspconfig.ltex.setup
  {:on_attach on-attach})

; Expose local methods
{: on-attach}
