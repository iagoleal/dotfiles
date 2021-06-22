-- Welcome to the XXI century
vim.cmd 'syntax enable'

-- Import utilities
local utils = require "utils"
utils.using(utils)

viml [[command! PackerInstall  lua require('plugins').install()
       command! PackerUpdate   lua require('plugins').update()
       command! PackerSync     lua require('plugins').sync()
       command! PackerClean    lua require('plugins').clean()
       command! -nargs=* PackerCompile  lua force_require('plugins').compile(<q-args>)
       command! PackerStatus   lua require('plugins').status()
       command! PackerProfile  lua require('plugins').profile_output()
       command! -nargs=+ -complete=customlist,v:lua.require'packer'.loader_complete PackerLoad lua require('plugins').loader(<q-args>)
]]

-- Auto reload plugins on startup
local plugins_path = vim.fn.stdpath('config') .. '/lua/plugins.lua'
augroup('PluginManager',
  {{'BufWritePost', plugins_path, ":PackerCompile profile=true"}})



-----------------------
-- Theme and colors
-----------------------
if has("termguicolors") then
  option "termguicolors"
  option("background", "dark")
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
option("listchars", {tab       = "├─"
                    , trail    = "۰"
                    , nbsp     = "☻"
                    , extends  = "⟩"
                    , precedes = "⟨"
                    })

option "number"                -- show line numbers
option "relativenumber"        -- Show line numbers relative to current line
option("numberwidth", 2)       -- set minimum width of numbers bar
option("signcolumn", "number") -- show (lsp) signs over number bar

option "showmatch"             -- highlight matching parentheses (useful as hell)


augroup('Ident',
  {{'FileType', '*', "setlocal formatoptions-=c formatoptions-=r formatoptions-=o"}})

-- No need for numbers and cursors on terminal lines
augroup('Terminal',
  {{'TermOpen', '*', "setlocal nonumber norelativenumber nocursorline nocursorcolumn"}})

-- Special Highlights
-- TODO: turn this into a theme setting
-- Head of a Fold
-- highlight("Folded",     {ctermbg="Black",   guibg="Black"})
-- Trailing spaces
highlight("Whitespace", {ctermfg="Magenta", guifg="Magenta"})
-- Matching Parentheses
-- highlight("MatchParen", {ctermfg="Magenta",cterm="underline", guibg="none", guifg="Magenta",  gui="Bold,Underline" })
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
option("wildmode", "full,list,full")   -- first autocomplete the word, afterwards run across the list

option "splitright"             -- Vertical split to the right (default is left)

-- Spaces and Tabs, settling the war
option("tabstop",     2)        -- n spaces per tab visually
option("softtabstop", 2)        -- n spaces per tab when editing
option("shiftwidth",  2)        -- n spaces for autoindent
option "expandtab"              -- If active, tabs are converted to spaces
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

-- Use ripgrep for :grep if possible
if has_executable("rg") then
    option('grepprg',    [[rg --vimgrep --no-heading]])
    option('grepformat', [[%f:%l:%c:%m,%f:%l:%m]])
end

----------------------
-- Keymaps
---------------------

-- <leader> key is Space
map('', '<Space>', '<Nop>', {noremap = true, silent = true})
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Exit terminal with ESC
map('t', "<Esc>", [[<C-\><C-n>]])
-- And use the default keybind to send ESC (This must be norecursive!!!)
map('t', [[<C-\><C-n>]], "<Esc>")

-- Disable search highlighting (until next search)
map('n', "<leader><Space>", "<cmd>nohlsearch<CR>")

-- Highlight cross around cursor
map('n', "<leader>cl", "<cmd>set cursorline! cursorcolumn!<CR>")

-- Zoom window at new tab
map('n', "<leader>tz", "<cmd>tab split<CR>")
-- Close tab
map('n', "<leader>tc", "<cmd>tabclose<CR>")

-- Spell checks previous mistake and corrects to first suggestion
map('i', "<C-l>", "<c-g>u<Esc>[s1z=`]a<c-g>u")

-- Search in visual mode
map('v', '*', [[y/\V<C-R>=escape(@",'/\')<CR><CR>]])


---- Navigation
local unimpaired = function(key, cmd)
  cmd = cmd or key
  local fmt = string.format
  map('n', "[" .. key:lower(), fmt(":<C-U>exe v:count1 '%sprevious'<CR>", cmd))
  map('n', "]" .. key:lower(), fmt(":<C-U>exe v:count1 '%snext'<CR>",     cmd))
  map('n', "[" .. key:upper(), fmt(":<C-U>exe v:count1 '%sfirst'<CR>",    cmd))
  map('n', "]" .. key:upper(), fmt(":<C-U>exe v:count1 '%slast'<CR>",     cmd))
end

unimpaired('q', 'c') -- Quickfix
unimpaired('l', 'l') -- Location list
unimpaired('b', 'b') -- Buffers
unimpaired('t', 't') -- Tabs

-- Plugin related

-- Open links with gx (netrw current version is bugged)
-- vim.g.loaded_netrwPlugin = 1
map('n', 'gx', [[<cmd>call netrw#BrowseX(expand((exists("g:netrw_gx")? g:netrw_gx : '<cfile>')),netrw#CheckIfRemote())<cr>]])

---- Building keymaps
map('n', "<leader>m", ":Dispatch<CR>")
map('n', "<leader>M", ":Dispatch!<CR>")

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
map('n', "<leader>if",       function()
  require('iron').core.send(vim.bo.filetype, vim.api.nvim_buf_get_lines(0, 0, -1, false))
end)

-- FZF
map('n', "<leader>fe", ":FZFFiles<cr>")
map('n', "<leader>fb", ":FZFBuffers<cr>")

-- Easy Align
map('n', "<leader>a", "<Plug>(EasyAlign)", {noremap = false})
map('x', "<leader>a", "<Plug>(EasyAlign)", {noremap = false})

-----------------------
-- Filetype Specific
-----------------------

augroup('Langs', {
    {"FileType", "scheme,racket,fennel",
      "setlocal softtabstop=2 shiftwidth=2 lisp autoindent"},
    {"FileType", "haskell",        "nnoremap <buffer> <space>hh :Hoogle <C-r><C-w><CR>"},
    {"FileType", "markdown,latex", "setlocal spell"},
    {"FileType", "make",           "setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=0"},
    {"FileType", "lua,fennel",     "nnoremap <buffer> <F12> :w<cr>:!love . &<cr>"}
})

----------------------
-- Configure Plugins
----------------------

-- Configure Iron Repl
local iron = require('iron')

iron.core.add_repl_definitions {
  lua = {
    luajit = { command = {"luajit"} },
    lua51  = { command = {"lua5.1"} },
    lua52  = { command = {"lua5.2"} },
    lua53  = { command = {"lua5.3"} },
    lua54  = { command = {"lua5.4"} },
    love   = { command = {"love", "."} }
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

iron.core.set_config {
  preferred = {
    lua     = "lua53",
    fennel  = "fennel",
    haskell = "stack",
    python  = "python",
    scheme  = "racket",
  },
  repl_open_cmd = "rightbelow 66 vsplit"
}

function iron_set_preferred(repl)
  local ft = vim.bo.filetype
  if repl == nil then
    local repls = vim.tbl_map(function(v) return v[1] end,
                              iron.core.list_definitions_for_ft(ft))
    table.sort(repls)
    local prompts = {}
    for k, v in ipairs(repls) do
      prompts[k] = string.format("%d. %s", k, v)
    end
    local choice = vim.fn.inputlist(prompts)
    repl = repls[choice]
  end
  iron.core.set_config {preferred = {[ft] = repl}}
end

viml [[command -nargs=? IronSetPreferred :lua iron_set_preferred(<f-args>)]]
