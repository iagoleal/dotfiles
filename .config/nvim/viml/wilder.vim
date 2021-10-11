" Only use wilder for command mode
call wilder#setup({'modes': [':']})

" Set the pipelines to use fuzzy finders
call wilder#set_option('pipeline', [
\ wilder#branch(
\   wilder#python_file_finder_pipeline({
\     'file_command': ['rg', '--files'],
\     'dir_command': ['find', '.', '-type', 'd', '-printf', '%P\n'],
\     'filters': ['fuzzy_filter', 'difflib_sorter'],
\   }),
\   wilder#substitute_pipeline({
\     'pipeline': wilder#python_search_pipeline({
\       'skip_cmdtype_check': 1,
\       'pattern': wilder#python_fuzzy_pattern({
\         'start_at_boundary': 0,
\       }),
\     }),
\   }),
\   wilder#cmdline_pipeline({
\     'fuzzy': 1,
\     'sorter': wilder#python_difflib_sorter(),
\     'fuzzy_filter': wilder#lua_fzy_filter(),
\   }),
\   [
\     wilder#check({_, x -> empty(x)}),
\     wilder#history(),
\   ],
\   wilder#python_search_pipeline({
\     'pattern': wilder#python_fuzzy_pattern({
\       'start_at_boundary': 0,
\     }),
\   }),
\ ),
\])

" Highlight using Lua (supposedly faster)
let s:highlighters = [
\ wilder#lua_pcre2_highlighter(),
\ wilder#lua_fzy_highlighter(),
\]

call wilder#set_option('renderer', wilder#wildmenu_renderer({
\ 'highlighter': s:highlighters,
\ 'highlights': {
\   'accent': wilder#make_hl('WilderAccent', 'Pmenu', [{}, {}, {'foreground': '#f4468f'}]),
\ },
\ 'separator': ' · ',
\ 'left': [' ', wilder#wildmenu_spinner(), ' '],
\ 'right': [' ', wilder#wildmenu_index()],
\ }))
