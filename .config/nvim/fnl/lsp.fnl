(local lspconfig (require :lspconfig))
(local {: keymap-buffer : autocmd}  (require :futils))
(local util lspconfig.util)

(import-macros {: augroup} :macros)

(macro require-use [pkg ...]
  `(. (require ,pkg) ,...))

(fn capable? [client capability]
  (. client.resolved_capabilities capability))

;;; Only map keybinds after attaching LSP
(fn on-attach [client bufnr]
  (let [bmap (fn [mode keys cmd ...]
               (keymap-buffer bufnr mode keys cmd :silent true ...))]

    ; Use lsp omnifunc for completion
    (tset vim.bo bufnr :omnifunc "v:lua.vim.lsp.omnifunc")

    ;; Mappings
    (bmap :n "K"          vim.lsp.buf.hover)
    (bmap :n "<C-k>"      vim.lsp.buf.signature_help)
    (bmap :n "gr"         vim.lsp.buf.references)
    (bmap :n "gD"         vim.lsp.buf.declaration)
    (bmap :n "gd"         vim.lsp.buf.definition)
    (bmap :n "g<C-d>"     vim.lsp.buf.implementation)
    (bmap :n "<leader>wa" vim.lsp.buf.add_workspace_folder)
    (bmap :n "<leader>wr" vim.lsp.buf.remove_workspace_folder)
    (bmap :n "<leader>wl" #(print (vim.inspect (vim.lsp.buf.list_workspace_folders))))
    (bmap :n "<leader>rn" vim.lsp.buf.rename)

    (when (capable? client :type_definition)
      (bmap :n "<leader>D" vim.lsp.buf.type_definition))
    (when (capable? client :code_action)
      (bmap :n "<leader>ca" vim.lsp.buf.code_action))
    (when (capable? client :code_lens)
      (bmap :n "<leader>cl" vim.lsp.codelens.run)
      (augroup :LspCodeLens
        (autocmd [:BufEnter :CursorHold :InsertLeave] "<buffer>" vim.lsp.codelens.refresh))
      (vim.lsp.codelens.refresh))

    ;; Diagnostics
    (bmap :n "<leader>e"  vim.diagnostic.open_float)
    (bmap :n "[d"         vim.diagnostic.goto_prev)
    (bmap :n "]d"         vim.diagnostic.goto_next)
    (bmap :n "<leader>dq" vim.diagnostic.setloclist)

    ;; Set some keybinds conditional on server capabilities
    (if (capable? client :document_range_formatting)
        (bmap :n "<leader>=" vim.lsp.buf.range_formatting)
        (capable? client :document_formatting)
        (bmap :n "<leader>=" vim.lsp.buf.formatting))))

;; Configure diagnostics (for all servers)
(vim.diagnostic.config {:virtual_text     false
                        :signs            true
                        :underline        false
                        :update_in_insert false
                        :severity_sort    true})
;;; Completion plugin
; (local cmp-capabilities
;   (let [default-capabilities (vim.lsp.protocol.make_client_capabilities)]
;     ((require-use :cmp_nvim_lsp :update_capabilities) default-capabilities)))

; (set vim.o.completeopt "menuone,longest")

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
   :cmd  [:julia
          :--startup-file=no
          :--history-file=no
          :-e
          "    # Load LanguageServer.jl: attempt to load from ~/.julia/environments/nvim-lspconfig
          # with the regular load path as a fallback
          ls_install_path = joinpath(
                                     get(DEPOT_PATH, 1, joinpath(homedir(), \".julia\")),
                                     \"environments\", \"nvim-lspconfig\"
                                     )
          pushfirst!(LOAD_PATH, ls_install_path)
          using LanguageServer
          popfirst!(LOAD_PATH)
          depot_path = get(ENV, \"JULIA_DEPOT_PATH\", \"\")
          project_path = let
          dirname(something(
                            ## 1. Finds an explicitly set project (JULIA_PROJECT)
                            Base.load_path_expand((
                                                   p = get(ENV, \"JULIA_PROJECT\", nothing);
                                                   p === nothing ? nothing : isempty(p) ? nothing : p
                                                   )),
                            ## 2. Look for a Project.toml file in the current working directory,
                            ##    or parent directories, with $HOME as an upper boundary
                            Base.current_project(),
                            ## 3. First entry in the load path
                            get(Base.load_path(), 1, nothing),
                            ## 4. Fallback to default global environment,
                            ##    this is more or less unreachable
                            Base.load_path_expand(\"@v#.#\"),
                            ))
          end
          @info \"Running language server\" VERSION pwd() project_path depot_path
          server = LanguageServer.LanguageServerInstance(stdin, stdout, project_path, depot_path)
          server.runlinter = true
          run(server) "]
   :single_file_support true
   :filetypes [:julia]})
   ; :on_new_config (fn [new-config new-root-dir]
   ;                  ; (local server-path "/home/iago/.julia/packages/LanguageServer/JrIEf/src")
   ;                  (local cmd ["julia"
   ;                              (.. "--project=" server-path)
   ;                              "--startup-file=no"
   ;                              "--history-file=no"
   ;                              "-e"
   ;                              "using Pkg;
   ;                               Pkg.instantiate()
   ;                               using LanguageServer; using SymbolServer;
   ;                               depot_path = get(ENV, \"JULIA_DEPOT_PATH\", \"\")
   ;                               project_path = dirname(something(Base.current_project(pwd()), Base.load_path_expand(LOAD_PATH[2])))
   ;                               # Make sure that we only load packages from this environment specifically.
   ;                               @info \"Running language server\" env=Base.load_path()[1] pwd() project_path depot_path
   ;                               server = LanguageServer.LanguageServerInstance(stdin, stdout, project_path, depot_path);
   ;                               server.runlinter = true;
   ;                               run(server);"])
   ;                  (set new-config.cmd cmd))})


;;; Python
(lspconfig.pyright.setup {:on_attach on-attach})

; Expose local methods
{: on-attach}
