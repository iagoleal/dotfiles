local wilder = require('wilder')

-- I don't like wilder while searching
wilder.setup {
  modes = {':'}
}

-- Disable Python remote plugin
wilder.set_option('use_python_remote_plugin', 0)


wilder.set_option('pipeline', {
  wilder.branch(
    wilder.cmdline_pipeline {
      fuzzy = 2,
      fuzzy_filter = wilder.lua_fzy_filter(),
    },
    wilder.vim_search_pipeline()
  )
})


wilder.set_option('renderer', wilder.renderer_mux {
  [':'] = wilder.wildmenu_renderer {
    highlighter = wilder.lua_fzy_highlighter(),
    highlights = {
      accent = wilder.make_hl('WilderAccent', 'Pmenu', {{a = 1}, {a = 1}, {foreground = '#f4468f'}}),
    },
    separator = ' · ',
    left = {
      ' ', wilder.wildmenu_spinner(), ' ',
    },
    right = {
      ' ', wilder.wildmenu_index()
    },
  },
})
