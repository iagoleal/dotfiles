(local lspconfig (require :lspconfig))
(local {: keymap-buffer}  (require :futils))

(fn capable? [client capability]
  (. client.resolved_capabilities capability))

;;; Only map keybinds after attaching LSP
(fn on-attach [client bufnr]
  (let [bmap (fn [mode keys cmd ...]
              (keymap-buffer bufnr mode keys cmd :silent true ...))]

    ; Use lsp omnifunc for completion
    (tset (. vim.bo bufnr) :omnifunc "v:lua.vim.lsp.omnifunc")

    ;; Mappings
    (bmap :n "gD"         vim.lsp.buf.declaration)
    (bmap :n "gd"         vim.lsp.buf.definition)
    (bmap :n "K"          vim.lsp.buf.hover)
    (bmap :n "g<C-d>"     vim.lsp.buf.implementation)
    (bmap :n "<C-k>"      vim.lsp.buf.signature_help)
    (bmap :n "<leader>wa" vim.lsp.buf.add_workspace_folder)
    (bmap :n "<leader>wr" vim.lsp.buf.remove_workspace_folder)
    (bmap :n "<leader>wl" #(print (vim.inspect (vim.lsp.buf.list_workspace_folders))))
    (when (capable? client :type_definition)
      (bmap :n "<leader>D" vim.lsp.buf.type_definition))
    (bmap :n "<leader>rn" vim.lsp.buf.rename)
    (bmap :n "gr"         vim.lsp.buf.references)
    (bmap :n "<leader>e"  vim.lsp.diagnostic.show_line_diagnostics)
    (bmap :n "[d"         vim.lsp.diagnostic.goto_prev)
    (bmap :n "]d"         vim.lsp.diagnostic.goto_next)
    (bmap :n "<leader>dq" vim.lsp.diagnostic.set_loclist)
    ;; Set some keybinds conditional on server capabilities
    (if (capable? client :document_range_formatting)
        (bmap :n "<leader>=" vim.lsp.buf.range_formatting)
        (capable? client :document_formatting)
        (bmap :n "<leader>=" vim.lsp.buf.formatting))))

;; Configure diagnostics (for all servers)
(tset vim.lsp.handlers :textDocument/publishDiagnostics
      (vim.lsp.with vim.lsp.diagnostic.on_publish_diagnostics
                    {:underline        false
                     :virtual_text     false
                     :update_in_insert false
                     :severity_sort    true}))

;--------------------------
; Server specific setups
;--------------------------

;;; Lua
;; set the path to the sumneko installation;
(let [sumneko-root-path "/usr/share/lua-language-server"
      sumneko-binary    "/bin/lua-language-server"
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
               (local x ((util.root_pattern :hadrian) fname))
               (when x
                 (lua "return x"))
               ((util.root_pattern :*.cabal :stack.yaml
                                   :cabal.project
                                   :package.yaml :hie.yaml) fname))})

;;; Julia
(lspconfig.julials.setup
  {:on_attach on-attach
   :autostart true
   :on_new_config (fn [new-config new-root-dir]
                    (local server-path "/home/iago/.julia/packages/LanguageServer/JrIEf/src")
                    (local cmd ["julia"
                                (.. "--project=" server-path)
                                "--startup-file=no"
                                "--history-file=no"
                                "-e"
                                "using Pkg;
                                 Pkg.instantiate()
                                 using LanguageServer; using SymbolServer;
                                 depot_path = get(ENV, \"JULIA_DEPOT_PATH\", \"\")
                                 project_path = dirname(something(Base.current_project(pwd()), Base.load_path_expand(LOAD_PATH[2])))
                                 # Make sure that we only load packages from this environment specifically.
                                 @info \"Running language server\" env=Base.load_path()[1] pwd() project_path depot_path
                                 server = LanguageServer.LanguageServerInstance(stdin, stdout, project_path, depot_path);
                                 server.runlinter = true;
                                 run(server);"])
                    (set new-config.cmd cmd))})


;;; Python
(lspconfig.pyright.setup {:on_attach on-attach})
