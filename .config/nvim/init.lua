-- Import utilities
local vim = vim
local utils = require "utils"
utils.using(utils)

-- Welcome to the XXI century
ex.syntax 'enable'

viml [[
  command! PackerInstall  lua require('plugins').install()
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

-- Special Highlights
function personal_highlights()
  -- Trailing spaces
  highlight("Whitespace", {ctermfg="Magenta", guifg="Magenta"})
  -- Spell checker colors
  highlight("SpellBad",   {ctermfg="Red",    cterm="Underline",  guifg="LightRed",   gui="Underline", guisp="LightRed"})
  highlight("SpellCap",   {ctermfg="Blue",   cterm="Underline",  guifg="LightBlue",  gui="Underline", guisp="Blue"})
  highlight("SpellLocal", {ctermfg="Green",  cterm="Underline",  guifg="LightGreen", gui="Underline", guisp="Green"})
  highlight("SpellRare",  {ctermfg="Yellow", cterm="underline",  guifg="Orange",     gui="Underline", guisp="Orange"})

  ex["runtime!"] "plugin/statusline.lua"
  ex["runtime!"] "plugin/tabline.lua"
end

-- Apply personal highlights when changing colorscheme
vim.cmd [[
augroup Highlights
  autocmd!
  autocmd ColorScheme * lua personal_highlights()
augroup END ]]

if has "termguicolors" then
  option "termguicolors"
  option("background", "dark")
  local colo = 'tokyonight'
  local status, err = pcall(colorscheme, colo)
  if not status then
    echoerr(err)
  end
end

option("synmaxcol", 180)
option("wrap", false)

option "showcmd"
option "ruler"
option("conceallevel", 0)

option "list" -- Show trailing {spaces, tabs}
option("listchars", { tab      = "├─"
                    , trail    = "۰"
                    , nbsp     = "☻"
                    , extends  = "⟩"
                    , precedes = "⟨"
                    } )

option "number"                -- show line numbers
option "relativenumber"        -- Show line numbers relative to current line
option("numberwidth", 2)       -- set minimum width of numbers bar
option("signcolumn", "number") -- show (lsp) signs over number bar

option "showmatch"             -- highlight matching parentheses (useful as hell)

--TODO
vim.opt.formatoptions:remove {'o', 'c', 'r'}

-- No need for numbers and cursors on terminal lines
augroup('Terminal',
  {{'TermOpen', '*', "setlocal nonumber norelativenumber nocursorline nocursorcolumn"}})

-- -- Highlight text on yank
augroup('Yank',
  {{'TextYankPost', '*', 'silent! lua vim.highlight.on_yank({higroup=”IncSearch”, timeout=150, on_visual=false})'}})

-------------------------
-- MISC options
-------------------------

option "lazyredraw"             -- Don't redraw screen during macros or register operations

-- Search
option "incsearch"              -- search as characters are entered
option "hlsearch"               -- highlight matches
option "ignorecase"             -- case-insensitive search / substitution
option "smartcase"              -- If terms are all lowercase, ignore case. Consider case otherwise.

option("inccommand", "nosplit") -- Show result of :s incrementally on buffer

-- Find files on subfolders
vim.opt.path:append '**'

option "wildmenu"                            -- visual menu for command autocompletion
option("wildmode", {"full", "list", "full"}) -- first autocomplete the word, afterwards run across the list

option "splitright"  -- Vertical split to the right (default is left)

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
vim.opt.thesaurus:append "~/.config/nvim/thesaurus/mthesaur.txt"

-- Use ripgrep for :grep if possible
if has_executable 'rg' then
    option('grepprg',    "rg --vimgrep --no-heading")
    option('grepformat', "%f:%l:%c:%m,%f:%l:%m")
end

---------------------
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
map('n', "<leader><Space>", "<cmd>set hlsearch!<CR>")

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

-- Enter path to current file on command mode
map('c', '<A-p>', [[getcmdtype() == ':' ? expand('%:h').'/' : '']], {expr = true})


-- Toggle quickfix window on the bottom of screen
toggle_quickfix = function()
  local windows = vim.fn.getwininfo()
  for _, win in pairs(windows) do
    if win.quickfix == 1 then
      vim.cmd 'cclose'
      return nil
    end
  end
  vim.cmd 'botright copen'
end

map('n', '<leader>q', toggle_quickfix)

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

-- Disable arrows
map('',  '<Up>',    '<Nop>')
map('',  '<Down>',  '<Nop>')
map('',  '<Left>',  '<Nop>')
map('',  '<Right>', '<Nop>')

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
    {"FileType", "markdown,latex,gitcommit", "setlocal spell"},
    {"FileType", "make",           "setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=0"},
    {"FileType", "lua,fennel",     "nnoremap <buffer> <F12> :wa<cr>:!love . &<cr>"}
})

-----------------------------
-- Disable Built-in plugins
-----------------------------

local disabled_built_ins = {
    -- "netrw",
    -- "netrwPlugin",
    -- "netrwSettings",
    -- "netrwFileHandlers",
    "gzip",
    "zip",
    "zipPlugin",
    "tar",
    "tarPlugin",
    "getscript",
    "getscriptPlugin",
    "vimball",
    "vimballPlugin",
    "2html_plugin",
    "logipat",
    "rrhelper",
    "spellfile_plugin",
    -- "matchit",
    -- "matchparen",
}

for _, plugin in ipairs(disabled_built_ins) do
    vim.g["loaded_" .. plugin] = 1
end
