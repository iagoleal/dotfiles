local api = {}

function api.highlight(mode, opts)
  local hi = {"highlight " .. mode}
  for k, v in pairs(opts) do
    table.insert(hi, " " .. k .. "=" .. v)
  end
  vim.cmd(table.concat(hi))
end

function api.augroup(name, autocmds)
    vim.cmd('augroup ' .. name)
    vim.cmd('autocmd!')

    for _, autocmd in ipairs(autocmds) do
        vim.cmd('autocmd ' .. table.concat(autocmd, ' '))
    end

    vim.cmd('augroup END')
end

return api
