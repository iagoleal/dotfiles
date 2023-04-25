pcall(require, "impatient")
vim.loader.enable()

-- Ensure that a given package is installed and loaded
local function echohl(text, hl)
  local emsg = vim.fn.escape(text, '"')
  vim.api.nvim_echo({{emsg, hl or ""}}, false, {})
end

local function bootstrap(name, repo, opt)
  local pack_type = opt and 'opt' or 'start'
  local pack_path = string.format("%s/site/pack/packer/%s/%s", vim.fn.stdpath('data'), pack_type, name)

  if vim.fn.empty(vim.fn.glob(pack_path)) > 0 then
    local answer = vim.fn.input(string.format("Package %s not found, do you want to load it? [Y/n]", name))

    if answer:match "^[nN]" then
      echohl("\nCloning aborted!", "WarningMsg")
    else
      echohl(string.format("\nCloning package '%s' as <<%s>> plugin", name, pack_type))
      vim.fn.system {'git', 'clone', repo, pack_path}
      vim.cmd.packadd(name)

      echohl(string.format('\nSucceded at cloning package %s.', name))
    end
  end
end

-- Ensure base packages are installed
bootstrap("packer.nvim",    "https://github.com/wbthomason/packer.nvim", true)
bootstrap("impatient.nvim", "https://github.com/lewis6991/impatient.nvim")
bootstrap("hotpot.nvim",    "https://github.com/rktjmp/hotpot.nvim")

-- Load real config written in Fennel
require("hotpot").setup({
  provide_require_fennel = true,
  compiler = {
    -- options passed to fennel.compile for modules, defaults to {}
    modules = {
      -- not default but recommended, align lua lines with fnl source
      -- for more debuggable errors, but less readable lua.
      correlate = true
    },
  },
})
require "startup"
