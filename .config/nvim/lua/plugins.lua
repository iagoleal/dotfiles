-- Ensure packer is installed
do
  local packer_repo = "https://github.com/wbthomason/packer.nvim"
  local packer_path = vim.fn.stdpath('data') .. "/site/pack/packer/start/packer.nvim"
  if vim.fn.empty(vim.fn.glob(packer_path)) > 0 then
    local answer = vim.fn.input("Packer not found, do you want to load it? [Y/n]")
    answer = string.lower(answer)
    if answer == "n" or answer == "no" then
      vim.cmd [[echohl WarningMsg]]
      vim.cmd [[redraw]]
      print("\nCloning aborted!")
      vim.cmd [[echohl None]]
      return nil
    end
    vim.cmd [[redraw]]
    print "\nCloning Packer as a start plugin"
    vim.fn.system({'git', 'clone', packer_repo, packer_path})
    vim.api.nvim_command 'packadd packer.nvim'
    vim.cmd [[redraw]]
    print "\nSucceded at cloning Packer"
  end
end

-- Plugin management
local packer = require('packer')
local use = packer.use

return packer.startup(function()
  -- The plugin manager itself
  use 'wbthomason/packer.nvim'
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
          vim.g.matchup_matchparen_offscreen           = {method = 'popup'}
          vim.g.matchup_matchparen_deferred            = 1
          vim.g.matchup_matchparen_hi_surround_always  = 1
          vim.g.matchup_matchparen_deferred_show_delay = 150
          vim.g.matchup_override_vimtex                = 0 -- let vimtex deal with matchs in tex files
          vim.g.matchup_matchpref = {
            html = {tagnameonly = 1}
          }
       end
      }
  -- use 'tpope/vim-dispatch'     -- Async make      (vimscript)
  use {'junegunn/vim-easy-align', -- Alignment utils (vimscript)
       config = function()
         vim.g.easy_align_delimiters = {
           ['>'] = {
             pattern         = [[=>\|->\|>\|→]],
             delimiter_align = 'r',
           },
           ['<'] = {
             pattern         = [[<-\|<=\|<\|←]],
             delimiter_align = 'l',
           }
         }
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
       disable = true,
       cmd    = {'RainbowToggle', 'RainbowToggleOn'},
       config = function()
         vim.g.rainbow_active = 0
       end
      }

  -- Color picker
  -- Can I remake this in lua with floating windows?
  use {'KabbAmine/vCoolor.vim',
       config = function()
         vim.g.vcoolor_disable_mappings = 1
         map('n', '<leader>ce', ':VCoolor<cr>')
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
  -- use {'JuliaEditorSupport/julia-vim', opt=false}
  use {'bakpakin/fennel.vim',    ft = 'fennel'}
  use {'wlangstroth/vim-racket', ft = 'racket'}
  use {'tikhomirov/vim-glsl',    ft = 'glsl'}
  -- use 'derekelkins/agda-vim'

  ---- Themes
  use 'ayu-theme/ayu-vim'
  use 'folke/tokyonight.nvim'
end)
