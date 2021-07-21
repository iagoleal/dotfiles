local nvim_lsp = require('lspconfig')

local function iscapable(client, capability)
  return client.resolved_capabilities[capability]
end

-- Only map keybinds after attaching LSP
local on_attach = function(client, bufnr)
  local opts = {noremap = true, silent = true}
  local function bmap(mode, keys, cmd)
    vim.api.nvim_buf_set_keymap(bufnr, mode, keys, cmd, opts)
  end

  -- Use lsp omnifunc for completion
  vim.bo[bufnr].omnifunc ='v:lua.vim.lsp.omnifunc'

  -- Mappings.
  bmap('n', 'gD',         '<cmd>lua vim.lsp.buf.declaration()<CR>')
  bmap('n', 'gd',         '<cmd>lua vim.lsp.buf.definition()<CR>')
  bmap('n', 'K',          '<cmd>lua vim.lsp.buf.hover()<CR>')
  bmap('n', 'gi',         '<cmd>lua vim.lsp.buf.implementation()<CR>')
  bmap('n', '<C-k>',      '<cmd>lua vim.lsp.buf.signature_help()<CR>')
  bmap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>')
  bmap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>')
  bmap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>')
  if iscapable(client, 'type_definition') then
    bmap('n', '<leader>D',  '<cmd>lua vim.lsp.buf.type_definition()<CR>')
  end
  bmap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
  bmap('n', 'gr',         '<cmd>lua vim.lsp.buf.references()<CR>')
  bmap('n', '<leader>e',  '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>')
  bmap('n', '[d',         '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
  bmap('n', ']d',         '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
  bmap('n', '<leader>dq',  '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>')
  -- Set some keybinds conditional on server capabilities
  if     iscapable(client, "document_range_formatting") then
    bmap("n", "<leader>=", "<cmd>lua vim.lsp.buf.range_formatting()<CR>")
  elseif iscapable(client, "document_formatting") then
    bmap("n", "<leader>=", "<cmd>lua vim.lsp.buf.formatting()<CR>")
  end
  print("LSP attached")
end

-- Configure diagnostics (for all servers)
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
 vim.lsp.diagnostic.on_publish_diagnostics, {
   underline        = true,
   virtual_text     = false,
   update_in_insert = false,
   severity_sort    = true,
 }
)

--------------------------
-- Server specific setups
--------------------------

-- Lua
-- set the path to the sumneko installation; if you previously installed via the now deprecated :LspInstall, use
do
  local sumneko_root_path = "/usr/share/lua-language-server"
  local sumneko_binary = "/bin/lua-language-server"
  local path = vim.split(package.path, ';')
  table.insert(path, "lua/?.lua")
  table.insert(path, "lua/?/init.lua")

  nvim_lsp.sumneko_lua.setup {
    on_attach = on_attach,
    cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"};
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
          -- Setup lua path
          path = path
        },
        diagnostics = {
          -- Get the language server to recognize `vim` and `love` globals
          globals = {'vim', 'love'},
          disable = {'lowercase-global'}
        },
        workspace = {
          preloadFileSize = 300,
          checkThirdParty = false,
          library = {
            -- Make the server aware of Neovim runtime files
            [vim.fn.expand('$VIMRUNTIME/lua')] = true,
            [vim.fn.stdpath('config')] = true,
            [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
            ["${3rd}/love2d/library"] = true,
          },
          [vim.fn.expand'~/.luarocks/share/lua/5.1'] = true,
          ['/usr/share/lua/5.1'] = true
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
          enable = false,
        },
      },
    },
  }
end

-- Haskell
nvim_lsp.hls.setup{
  on_attach = on_attach
}

-- Julia
nvim_lsp.julials.setup{
    on_attach = on_attach,
    autostart = true,
    on_new_config = function(new_config, new_root_dir)
      local server_path = "/home/iago/.julia/packages/LanguageServer/y1ebo/src"
      local cmd = {
        "julia",
        "--project="..server_path,
        "--startup-file=no",
        "--history-file=no",
        "-e", [[
          using Pkg;
          Pkg.instantiate()
          using LanguageServer; using SymbolServer;
          depot_path = get(ENV, "JULIA_DEPOT_PATH", "")
          project_path = dirname(something(Base.current_project(pwd()), Base.load_path_expand(LOAD_PATH[2])))
          # Make sure that we only load packages from this environment specifically.
          @info "Running language server" env=Base.load_path()[1] pwd() project_path depot_path
          server = LanguageServer.LanguageServerInstance(stdin, stdout, project_path, depot_path);
          server.runlinter = true;
          run(server);
        ]]
    };
      new_config.cmd = cmd
    end
}

-- Python
nvim_lsp.pyright.setup {
    on_attach = on_attach
}
