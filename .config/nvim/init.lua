-- Caching of lua modules
vim.loader.enable()

-- Ensure that a given package is installed and loaded
local function bootstrap(name, repo, opt)
  local pack_type = opt and 'opt' or 'start'
  local pack_path = string.format("%s/site/pack/packer/%s/%s", vim.fn.stdpath('data'), pack_type, name)

  if vim.fn.empty(vim.fn.glob(pack_path)) > 0 then
    local answer = vim.fn.input(string.format("Package %s not found, do you want to load it? [Y/n]", name))
    if answer:match "^[nN]" then
      vim.notify("Cloning aborted!", vim.log.levels.WARN)
    else
      vim.notify(string.format("\nCloning package '%s' as <<%s>> plugin", name, pack_type))
      vim.fn.system {'git', 'clone', repo, pack_path}
      vim.cmd.packadd(name)

      vim.notify(string.format('\nSucceded at cloning package %s.', name))
    end
  end
end

-- Ensure base packages are installed
bootstrap("packer.nvim",    "https://github.com/wbthomason/packer.nvim", true)
bootstrap("hotpot.nvim",    "https://github.com/rktjmp/hotpot.nvim")

-- Load real config written in Fennel
require("hotpot").setup({
  provide_require_fennel    = true,
  enable_hotpot_diagnostics = false,
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
