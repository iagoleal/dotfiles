-- Welcome to the XXI century
vim.cmd 'filetype plugin indent on'
vim.cmd 'syntax enable'

-- Import utilities
require "utils"

-- Ensure packer is installed
do
  local packer_repo = "https://github.com/wbthomason/packer.nvim"
  local packer_path = vim.fn.stdpath('data') .. "/site/pack/packer/start/packer.nvim"
  if vim.fn.empty(vim.fn.glob(packer_path)) > 0 then
    vim.fn.system({'git', 'clone', packer_repo, packer_path})
    vim.api.nvim_command 'packadd packer.nvim'
  end
end

-- Plugin management
local packer = require('packer')
local use = packer.use
packer.startup(function()
  -- The plugin manager itself
  use {'wbthomason/packer.nvim'}
  -- Treesitter
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
  use {'p00f/nvim-ts-rainbow',
       requires = 'nvim-treesitter/nvim-treesitter'
      }
  -- LSP
  use {'neovim/nvim-lspconfig',
       config = function()
        require "lsp"
       end
      }
  -- REPL
  use {'hkupty/iron.nvim',
       config = function()
         vim.g.iron_map_defaults = 0
         vim.g.iron_map_extended = 1
       end
      }
  -- Fuzzy Search
  use {'junegunn/fzf.vim',
       config = function()
         vim.g.fzf_command_prefix = 'FZF'
       end
      }
  use {'monkoose/fzf-hoogle.vim', ft = 'haskell'}

  -- Major utilities
  use {'terrortylor/nvim-comment',
       config = function()
         require('nvim_comment').setup({comment_empty = false})
       end
      }

  use 'tpope/vim-surround'        -- Edit surrounding objects (vimscript)
  use {'andymass/vim-matchup',    -- Improved matchparen and matchit
       config = function()
          vim.g.loaded_matchit = 1 -- Disable matchit
          vim.g.matchup_matchparen_offscreen = {method = 'popup'}
          vim.g.matchup_matchparen_deferred = 1
          vim.g.matchup_matchparen_hi_surround_always = 1
          vim.g.matchup_override_vimtex = 0 -- let vimtex deal with matchs in tex files
          vim.g.matchup_matchpref = {
            html = {tagnameonly = 1}
          }
       end
      }
  -- use 'tpope/vim-dispatch'     -- Async make      (vimscript)
  use {'junegunn/vim-easy-align', -- Alignment utils (vimscript)
       config = function()
         map('n', "<leader>a", "<Plug>(EasyAlign)", {noremap = false})
         map('x', "<leader>a", "<Plug>(EasyAlign)", {noremap = false})
       end
      }
  use {'norcalli/nvim-colorizer.lua',
       cmd    = {'ColorizerToggle', 'ColorizerReloadAllBuffers', 'ColorizerAttachToBuffer'},
       config = function()
         require("colorizer").setup()
       end
      }
  -- Colorize parentheses
  use {'luochen1990/rainbow',
       cmd    = {'RainbowToggleOn', 'RainbowToggle'},
       config = function()
         vim.g.rainbow_active = 0
       end
      }

  -- Color picker
  -- Can I remake this in lua with floating windows?
  use {'KabbAmine/vCoolor.vim',
       config = function()
         vim.g.vcoolor_map = '<leader>ce'
        end
      }

  ---- Filetype specific
  use {'lervag/vimtex',
       ft = 'tex',
       config = function()
         vim.g.tex_flavor                                 = 'latex'
         vim.g.vimtex_view_method                         = 'zathura'
         vim.g.vimtex_compiler_progname                   = 'nvr'
         vim.g.vimtex_quickfix_mode                       = 2
         vim.g.vimtex_quickfix_autoclose_after_keystrokes = 2
         vim.g.vimtex_quickfix_open_on_warning            = 1
         vim.g.vimtex_indent_enabled                      = 0
         vim.g.vimtex_indent_delims                       = {}
       end
      }
  use {'plasticboy/vim-markdown',
       ft = 'markdown',
       config = function()
         vim.g.vim_markdown_folding_disabled     = 1
         vim.g.vim_markdown_conceal              = 0
         vim.g.vim_markdown_fenced_languages     = {'c++=cpp', 'viml=vim', 'bash=sh', 'ini=dosini'}
         vim.g.vim_markdown_math                 = 1
         vim.g.vim_markdown_frontmatter          = 1
         vim.g.vim_markdown_new_list_item_indent = 4
       end
      }
  use {'neovimhaskell/haskell-vim',
       ft = 'haskell',
       config = function()
         vim.g.haskell_enable_quantification   = 1   -- to enable highlighting of `forall`
         vim.g.haskell_enable_recursivedo      = 1   -- to enable highlighting of `mdo` and `rec`
         vim.g.haskell_enable_arrowsyntax      = 1   -- to enable highlighting of `proc`
         vim.g.haskell_enable_pattern_synonyms = 1   -- to enable highlighting of `pattern`
         vim.g.haskell_enable_typeroles        = 1   -- to enable highlighting of type roles
         vim.g.haskell_enable_static_pointers  = 1   -- to enable highlighting of `static`
         vim.g.haskell_backpack                = 1   -- to enable highlighting of backpack keywords
         vim.g.haskell_indent_case_alternative = 1
         vim.g.haskell_indent_if               = 1
         vim.g.haskell_indent_case             = 2
         vim.g.haskell_indent_let              = 4
         vim.g.haskell_indent_where            = 10
         vim.g.haskell_indent_before_where     = 1
         vim.g.haskell_indent_after_bare_where = 1
         vim.g.haskell_indent_do               = 3
         vim.g.haskell_indent_in               = 0
         vim.g.haskell_indent_guard            = 2
       end
      }
  use {'JuliaEditorSupport/julia-vim', opt=false}
  use {'bakpakin/fennel.vim',    ft = 'fennel'}
  use {'wlangstroth/vim-racket', ft = 'racket'}
  use {'tikhomirov/vim-glsl',    ft = 'glsl'}
  -- use 'derekelkins/agda-vim'

  ---- Themes
  use 'ayu-theme/ayu-vim'
  use 'folke/tokyonight.nvim'
end)

require("async_make")

-----------------------
-- Theme and colors
-----------------------
if vim.fn.has("termguicolors") == 1 then
  vim.o.termguicolors = true
  vim.o.background = "dark"
  vim.cmd 'let ayucolor="mirage"'
  colorscheme "tokyonight"
end

-- Use custom status and tabline
require "statusline"
require "tabline"

option("synmaxcol", 180)
option("wrap", false)

option("showcmd", true)
option("ruler", true)
option("conceallevel", 0)

option("list", true)                  -- Show trailing {spaces, tabs}
option("listchars", {"tab:├─", "trail:۰", "nbsp:☻", "extends:⟩", "precedes:⟨"})

option("number", true)                -- show line numbers)
option("relativenumber", true)        -- Show line numbers relative to current line
option("numberwidth", 2)              -- set minimum width of numbers bar
option("showmatch", true)             -- highlight matching parentheses (useful as hell)


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
highlight("MatchParen", {guibg="none", guifg="Magenta", ctermfg="Magenta", gui="Bold,Underline", cterm="underline"})
-- Spell checker colors
highlight("SpellBad",   {ctermfg="Red",    cterm="Underline",  guifg="LightRed",   gui="Underline", guisp="LightRed"})
highlight("SpellCap",   {ctermfg="Blue",   cterm="Underline",  guifg="LightBlue",  gui="Underline", guisp="Blue"})
highlight("SpellLocal", {ctermfg="Green",  cterm="Underline",  guifg="LightGreen", gui="Underline", guisp="Green"})
highlight("SpellRare",  {ctermfg="Yellow", cterm="underline",  guifg="Orange",     gui="Underline", guisp="Orange"})


-------------------------
-- MISC options
-------------------------

-- Search
option("incsearch", true)              -- search as characters are entered
option("hlsearch", true)               -- highlight matches
option("ignorecase", true)             -- case-insensitive searchs / substitutions
option("smartcase", true)              -- If terms are all lowercase, ignore case. Consider case otherwise.

-- Find files on subfolders
vim.o.path = vim.o.path .. '**'

option("wildmenu", true)               -- visual menu for command autocompletion
option("wildmode",{"full", "list", "full"})   -- first autocomplete the word, afterwards run across the list

option("splitright", true)             -- Vertical split to the right (default is left)

-- Spaces and Tabs, settling the war
option("tabstop",     2)       -- n spaces per tab visually
option("softtabstop", 2)       -- n spaces per tab when editing
option("shiftwidth",  2)       -- n spaces for autoindent
option("expandtab",   true)    -- If active, tabs are converted to spaces
option("smarttab",    false)

-- Indentation
option("autoindent", true)

-- Set backup files
option("backup", true)
option("backupdir",  {"~/.vim/tmp", "~/.tmp", "~/tmp", "/var/tmp", "/tmp", "."})
option("backupskip", {"/tmp/*", "/private/tmp/*"})
option("directory",  {"~/.vim/tmp", "~/.tmp", "~/tmp", "/var/tmp", "/tmp"})
option("writebackup", true)

-- Set undo
option("undodir", {"~/.tmp", "~/tmp", "/var/tmp", "/tmp", "$XDG_DATA_HOME/nvim/undo", "."})
option("undofile", true)

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
map('n', "<leader>ic",       "<plug>(iron-interrupt)",     {noremap = false})
map('n', "<leader>iq",       "<Plug>(iron-exit)",          {noremap = false})
map('n', "<leader>il",       "<Plug>(iron-clear)",         {noremap = false})
map('n', "<leader>ip",       "<Plug>(iron-send-motion)ip", {noremap = false})
map('n', "<leader>is",       ":IronRepl<CR>")
map('n', "<leader>ir",       ":IronRestart<CR>")
map('n', "<leader>if",       "<Cmd>lua require('iron').core.send(vim.api.nvim_buf_get_option(0,'ft'), vim.api.nvim_buf_get_lines(0, 0, -1, false))<Cr>")

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
  ensure_installed = {"bash", "c", "comment", "css", "fennel", "haskell", "html", "json", "julia", "lua", "python"}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  highlight = {
    enable = true,
    -- https://www.reddit.com/r/neovim/comments/n9aupn/set_spell_that_only_considers_code_comments/
    additional_vim_regex_highlighting = true
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
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
    lua53 = { command = {"lua5.3"} }
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
    chez = { command = {"scheme"} },
    racket = { command = {"racket", "-il", "scheme"} }
  }
}

require("iron").core.set_config {
  preferred = {
    lua     = "luajit",
    fennel  = "fennel",
    haskell = "stack",
    python  = "python",
    scheme  = "racket",
  },
  repl_open_cmd = "rightbelow 66 vsplit"
}
