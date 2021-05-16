-- Welcome to the XXI century
vim.cmd 'filetype plugin indent on'
vim.cmd 'syntax enable'

-- Import utilities
require "utils"

-- Plugin management
require "plugins"

-- Auto reload plugins on startup
local plugins_path = vim.fn.stdpath('config') .. '/lua/plugins.lua'
augroup('PluginManager',
  {{'BufWritePost', plugins_path, "lua package.loaded.plugins = nil; require('plugins').compile()"}})


-- Async tools
require "async_make"
require "async_grep"

-----------------------
-- Theme and colors
-----------------------
if vim.fn.has("termguicolors") == 1 then
  vim.o.termguicolors = true
  vim.o.background = "dark"
  vim.g.ayucolor = 'mirage'
  colorscheme "tokyonight"
end

-- Use custom status and tabline
require "statusline"
require "tabline"

option("synmaxcol", 180)
option("wrap", false)

option "showcmd"
option "ruler"
option("conceallevel", 0)

option "list"                  -- Show trailing {spaces, tabs}
option("listchars", {"tab:├─", "trail:۰", "nbsp:☻", "extends:⟩", "precedes:⟨"})

option "number"                -- show line numbers)
option "relativenumber"        -- Show line numbers relative to current line
option("numberwidth", 2)       -- set minimum width of numbers bar
option "showmatch"             -- highlight matching parentheses (useful as hell)


augroup('Ident',
  {{'FileType', '*', "setlocal formatoptions-=c formatoptions-=r formatoptions-=o"}})

-- No need for numbers and cursors on terminal lines
augroup('Terminal',
  {{'TermOpen', '*', "setlocal nonumber norelativenumber nocursorline nocursorcolumn"}})


-- Special Highlights
-- TODO: turn this into a theme setting
-- Head of a Fold
highlight("Folded",     {ctermbg="Black",   guibg="Black"})
-- Trailing spaces
highlight("Whitespace", {ctermfg="Magenta", guifg="Magenta"})
-- Matching Parentheses
highlight("MatchParen", {ctermfg="Magenta",cterm="underline", guibg="none", guifg="Magenta",  gui="Bold,Underline" })
-- Spell checker colors
highlight("SpellBad",   {ctermfg="Red",    cterm="Underline",  guifg="LightRed",   gui="Underline", guisp="LightRed"})
highlight("SpellCap",   {ctermfg="Blue",   cterm="Underline",  guifg="LightBlue",  gui="Underline", guisp="Blue"})
highlight("SpellLocal", {ctermfg="Green",  cterm="Underline",  guifg="LightGreen", gui="Underline", guisp="Green"})
highlight("SpellRare",  {ctermfg="Yellow", cterm="underline",  guifg="Orange",     gui="Underline", guisp="Orange"})


-------------------------
-- MISC options
-------------------------

-- Search
option "incsearch"              -- search as characters are entered
option "hlsearch"               -- highlight matches
option "ignorecase"             -- case-insensitive searchs / substitutions
option "smartcase"              -- If terms are all lowercase, ignore case. Consider case otherwise.

-- Find files on subfolders
vim.o.path = vim.o.path .. '**'

option "wildmenu"               -- visual menu for command autocompletion
option("wildmode",{"full", "list", "full"})   -- first autocomplete the word, afterwards run across the list

option "splitright"             -- Vertical split to the right (default is left)

-- Spaces and Tabs, settling the war
option("tabstop",     2)       -- n spaces per tab visually
option("softtabstop", 2)       -- n spaces per tab when editing
option("shiftwidth",  2)       -- n spaces for autoindent
option "expandtab"             -- If active, tabs are converted to spaces
option("smarttab",    false)

-- Indentation
option "autoindent"

-- Set backup files
option "backup"
option("backupdir",  {"~/.vim/tmp", "~/.tmp", "~/tmp", "/var/tmp", "/tmp", "."})
option("backupskip", {"/tmp/*", "/private/tmp/*"})
option("directory",  {"~/.vim/tmp", "~/.tmp", "~/tmp", "/var/tmp", "/tmp"})
option "writebackup"

-- Set undo
option("undodir", {"~/.tmp", "~/tmp", "/var/tmp", "/tmp", "$XDG_DATA_HOME/nvim/undo", "."})
option "undofile"

-- Set Thesaurus file
vim.o.thesaurus = vim.o.thesaurus .. "~/.config/nvim/thesaurus/mthesaur.txt"

----------------------
-- Keymaps
---------------------

-- <leader> key is Space
map('', '<Space>', '<Nop>', {noremap = true, silent = true})
vim.g.mapleader = " "

-- Exit terminal with ESC
map('t', "<Esc>", [[<C-\><C-n>]])
-- And use the default keybind to send ESC (This must be norecursive!!!)
map('t', [[<C-\><C-n>]], "<Esc>")

-- Disable search highlighting (until next search)
map('n', "<leader><Space>", ":nohlsearch<CR>")

-- Highlight cross around cursor
map('n', "<leader>cl", ":set cursorline! cursorcolumn!<CR>")

-- Spell checks previous mistake and corrects to first suggestion
map('i', "<C-l>", "<c-g>u<Esc>[s1z=`]a<c-g>u")

---- Navigation
-- Quickfix
map('n', "]q", ":cnext<cr>zz")
map('n', "[q", ":cprev<cr>zz")
map('n', "]l", ":lnext<cr>zz")
map('n', "[l", ":lprev<cr>zz")
-- Buffers
map('n', "]b", ":bnext<cr>")
map('n', "[b", ":bprev<cr>")
-- Tabs
map('n', "]t", ":tabnext<cr>")
map('n', "[t", ":tabprevious<cr>")

---- Building keymaps
map('n', "<leader>m", ":Make<CR>")
-- nnoremap <leader>M :w<CR>:Dispatch!<CR>

-- Toggle Color Highlight
map('n', "<leader>cc", ":ColorizerToggle<CR>")
-- Toggle Rainbow Parentheses
map('n', "<leader>cr", ":RainbowToggle<CR>")

-- REPL
map('n', "<leader>it",       "<Plug>(iron-send-motion)",   {noremap = false})
map('v', "<leader>i<Space>", "<Plug>(iron-visual-send)",   {noremap = false})
map('n', "<leader>i.",       "<Plug>(iron-repeat-cmd)",    {noremap = false})
map('n', "<leader>i<Space>", "<Plug>(iron-send-line)",     {noremap = false})
map('n', "<leader>ii",       "<Plug>(iron-send-line)",     {noremap = false})
map('n', "<leader>i<CR>",    "<Plug>(iron-cr)",            {noremap = false})
map('n', "<leader>ic",       "<Plug>(iron-interrupt)",     {noremap = false})
map('n', "<leader>iq",       "<Plug>(iron-exit)",          {noremap = false})
map('n', "<leader>il",       "<Plug>(iron-clear)",         {noremap = false})
map('n', "<leader>ip",       "<Plug>(iron-send-motion)ip", {noremap = false})
map('n', "<leader>is",       ":IronRepl<CR>")
map('n', "<leader>ir",       ":IronRestart<CR>")
map('n', "<leader>if",       "<Cmd>lua require('iron').core.send(vim.api.nvim_buf_get_option(0,'ft'), vim.api.nvim_buf_get_lines(0, 0, -1, false))<Cr>")

-- FZF
map('n', "<leader>fe", ":FZFFiles<cr>")
map('n', "<leader>fb", ":FZFBuffers<cr>")

-----------------------
-- Filetype Specific
-----------------------

augroup('Langs', {
    {"FileType", "scheme",   "setlocal softtabstop=2   shiftwidth=2 lisp autoindent"},
    {"FileType", "haskell",  "nnoremap <buffer> <space>hh :Hoogle <C-r><C-w><CR>"},
    {"FileType", "markdown", "setlocal spell"},
    {"FileType", "latex",    "setlocal spell"},
    {"FileType", "make",     "setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=0"}
})

----------------------
-- Configure Plugins
----------------------

-- Configure Treesitter
require'nvim-treesitter.configs'.setup {
  ensure_installed = {"bash", "bibtex", "c", "comment", "cpp", "css", "fennel", "haskell", "html", "javascript", "json", "julia", "latex", "lua", "python", "yaml"}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  highlight = {
    enable = true,
    -- https://www.reddit.com/r/neovim/comments/n9aupn/set_spell_that_only_considers_code_comments/
    additional_vim_regex_highlighting = true
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection    = "gnn",
      node_incremental  = "grn",
      scope_incremental = "grc",
      node_decremental  = "grm",
    },
  },
  indent = {
    enable = true
  },
  -- External plugins
  rainbow = {
    enable = true,
  },
  matchup = {
    enable = true
    -- disable = { },  -- optional, list of language that will be disabled
  },
}

-- Configure Iron Repl
local iron = require('iron')

iron.core.add_repl_definitions {
  lua = {
    luajit = { command = {"luajit"} },
    lua51  = { command = {"lua5.1"} },
    lua52  = { command = {"lua5.2"} },
    lua53  = { command = {"lua5.3"} },
    lua54  = { command = {"lua5.4"} }
  },
  fennel = {
    love = { command = {"love", "."} }
  },
  haskell = {
    stack = {
      command = {"stack", "ghci"},
      open    = ":{",
      close   = {":}", ""}
    }
  },
  scheme = {
    chez   = { command = {"scheme"} },
    racket = { command = {"racket", "-il", "scheme"} }
  }
}

require("iron").core.set_config {
  preferred = {
    lua     = "lua53",
    fennel  = "fennel",
    haskell = "stack",
    python  = "python",
    scheme  = "racket",
  },
  repl_open_cmd = "rightbelow 66 vsplit"
}
