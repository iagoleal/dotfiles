vim.loader.enable()
require('impatient')

-- Ensure that a given package is installed and loaded
local function bootstrap(name, repo, opt)
  local pack_type = opt and 'opt' or 'start'
  local pack_path = string.format("%s/site/pack/packer/%s/%s", vim.fn.stdpath('data'), pack_type, name)

  if vim.fn.empty(vim.fn.glob(pack_path)) > 0 then
    local answer = vim.fn.input("Package " .. name .. " not found, do you want to load it? [Y/n]")
    answer = string.lower(answer)

    local function echohl(text, hl)
      hl = hl or ""
      local emsg = vim.fn.escape(text, '"')
      vim.api.nvim_echo({{emsg, hl}}, false, {})
    end

    if answer == "n" or answer == "no" then
      echohl("\nCloning aborted!", "WarningMsg")
      return nil
    end

    echohl(string.format("\nCloning package %s as an %s plugin", name, pack_type))
    vim.fn.system {'git', 'clone', repo, pack_path}
    vim.api.nvim_command('packadd ' .. name)
    echohl(string.format('\nSucceded at cloning package %s.', name))
  end
end

-- Ensure base packages are installed
bootstrap("packer.nvim",    "https://github.com/wbthomason/packer.nvim", true)
bootstrap("hotpot.nvim",    "https://github.com/rktjmp/hotpot.nvim")
bootstrap("impatient.nvim", "https://github.com/lewis6991/impatient.nvim")

-- Load real config written in Fennel
require "hotpot"
require "startup"
