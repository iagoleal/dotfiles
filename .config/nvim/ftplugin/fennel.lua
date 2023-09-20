vim.opt_local.include = [[\v\(require\s+(:|")\zs[^"]+\ze"?)]]
vim.opt_local.includeexpr = "v:lua.require('ft.lua').find_required_path(v:fname)"
