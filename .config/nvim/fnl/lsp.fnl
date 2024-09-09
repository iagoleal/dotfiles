(local lspconfig (require :lspconfig))
(local {: keymap/buffer}  (require :editor))
(local util lspconfig.util)


;;--------------------------------------------------
;; Per buffer settings
;;--------------------------------------------------

(local GenLspConfig (vim.api.nvim_create_augroup :GenLspConfig {:clear true}))

(fn on-attach [{:buf bufnr : data}]
  (let [client   (vim.lsp.get_client_by_id data.client_id)
        ; Check whether a LSP client can provide a certain server capability
        capable? #(. client.server_capabilities $...)
        bmap     (keymap/buffer bufnr)]
    ;; Mappings
    (when (capable? :signatureHelpProvider)
      (bmap :n "<C-k>"      vim.lsp.buf.signature_help
        {:desc "LSP Signature Help"}))

    (when (capable? :referencesProvider)
      (bmap :n "<leader>re" vim.lsp.buf.references
        {:desc "LSP References"})
      (bmap :n "gr"         vim.lsp.buf.references
        {:desc "LSP References"}))
    (when (capable? :renameProvider)
      (bmap :n "<leader>rn" vim.lsp.buf.rename
        {:desc "Rename symbol under cursor"}))

    (when (capable? :definitionProvider)
      (bmap :n "gd"         vim.lsp.buf.definition
        {:desc "Go to definition"}))
    (when (capable? :typeDefinitionProvider)
      (bmap :n "gy"         vim.lsp.buf.type_definition
        {:desc "Go to type definition"}))
    (when (capable? :declarationProvider)
      (bmap :n "gD"         vim.lsp.buf.declaration
        {:desc "Go to declaration"}))
    (when (capable? :implementationProvider)
      (bmap :n "gI"         vim.lsp.buf.implementation
        {:desc "Go to implementation"}))

    (when (capable? :codeActionProvider)
      (bmap :n "<leader>ca" vim.lsp.buf.code_action
        {:desc "Execute Code Action under cursor"}))

    (when (capable? :codeLensProvider)
      (bmap :n "<leader>cl" vim.lsp.codelens.run
          {:desc "Execute Code Lens under cursor"})
      ;;
      (vim.api.nvim_create_autocmd [:BufEnter :CursorHold :InsertLeave]
        {:group    GenLspConfig
         :callback #(vim.lsp.codelens.refresh {:bufnr 0})
         :buffer   bufnr
         :desc     "Refresh all Code Lenses"}))

    ;; Workspaces
    (bmap :n "<leader>wa" vim.lsp.buf.add_workspace_folder)
    (bmap :n "<leader>wr" vim.lsp.buf.remove_workspace_folder)
    (bmap :n "<leader>wl" #(print (vim.inspect (vim.lsp.buf.list_workspace_folders))))))


(vim.api.nvim_create_autocmd :LspAttach
  {:group    GenLspConfig
   :callback on-attach})


;;--------------------------------------------------
;; Handlers with improved functionality
;;--------------------------------------------------

;; From https://www.reddit.com/r/neovim/comments/12fburw/feedback_when_lsp_dont_find_definition/
(let [actual-handler vim.lsp.handlers.textDocument/definition]
  (tset vim.lsp.handlers :textDocument/definition
    (fn [err result context config]
      (when (not result)
        (vim.notify "Definition not found"))
      (actual-handler err result context config))))


;;--------------------------------------------------
;; Server specific setups
;;--------------------------------------------------

;;; Lua
;; set the path to the sumneko installation;
(let [lpath (vim.split package.path ";")]
  (table.insert lpath "lua/?.lua")
  (table.insert lpath "lua/?/init.lua")
  (lspconfig.lua_ls.setup
    {:settings
       {:Lua
         {:runtime
            {:version "LuaJIT"
             ; Setup lua path
             :path    lpath}
          :diagnostics {:globals [:vim :love :pandoc]
                        :disable [:lowercase-global]}
          :workspace
            {:preloadFileSize 300
             :checkThirdParty false
             :library
               ;; Make the server aware of Neovim and love2d runtime files
               [(vim.api.nvim_get_runtime_file "" true)
                "${3rd}/love2d/library"
                (vim.fn.expand "~/.luarocks/share/lua/5.1")
                "/usr/share/lua/5.1"]}
          ; Do NOT send telemetry data
          :telemetry {:enable false}}}}))


;;; Haskell
(lspconfig.hls.setup
  {:root_dir (fn [fname]
              ((util.root_pattern :*.cabal :stack.yaml :cabal.project :package.yaml :hie.yaml :*.hs) fname))
   :settings
     {:haskell
        {:plugin
          {:wingman
            {:config {:proofstate_styling true
                      :timeout_duration 5}}}}}})

;;; Julia
(lspconfig.julials.setup
  {:autostart true
   :root_dir (fn [fname]
               (or ((util.root_pattern "Project.toml") fname)
                   (util.find_git_ancestor fname)))
   :single_file_support true
   :filetypes [:julia]})


;;; Fennel

(lspconfig.fennel_ls.setup
  {:root_dir #(. (vim.fs.find ["fnl" ".git"]
                              {:upward true :type :directory :path $})
                 1)
   :settings {:fennel-ls {:extra-globals "vim"}}})


;;; Python
(lspconfig.pyright.setup {})


;;; C / C++
(lspconfig.ccls.setup {})


;;; Bash
(lspconfig.bashls.setup {})


;;; Javascript / Typescript
(lspconfig.ts_ls.setup {})


;;; Prose
(lspconfig.ltex.setup
  {:settings {:ltex {:additionalRules {:languageModel (.. (vim.fn.stdpath :data) "/ngrams")}}}})
