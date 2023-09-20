-- Set options to open require with gf

-- This regex matches lua's dofile, loadfile and require syntax
vim.opt_local.include = [=[\v<((do|load)file|require)\s*\(?['"]\zs[^'"]+\ze['"]]=]
vim.opt_local.includeexpr = "v:lua.require('ft.lua').find_required_path(v:fname)"
