function CursorMode()
    local mode_map = {
        ['n'] = 'Normal',
        ['v'] = 'VISUAL',
        ['V'] = 'V-LINE',
        [''] = 'V-BLOCK',
        ['i'] = 'INSERT',
        ['R'] = 'REPLACE',
        ['Rv'] = 'V-REPLACE',
        ['c'] = 'COMMAND',
    }

    return mode_map[vim.fn.mode()]
end

function StatusLine()
    local sl = ''
    sl = sl .. [[%-{luaeval("CursorMode()")}]]
    sl = sl .. [[ %-t %-m %-r]]
    sl = sl .. [[%{get(b:,'gitsigns_head','')}]]
    sl = sl .. [[ %{get(b:,'gitsigns_status','')}]]

    sl = sl .. [[ %= %y %l:%L]]
    return sl
end

vim.o.laststatus = 2
vim.o.showmode   = false
vim.o.statusline = StatusLine()
