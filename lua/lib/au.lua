local M = {}
M.__index = M

function M.NewGroup(name, clear)
    local ret = setmetatable({}, M)
    clear = clear or true
    ret.group = vim.api.nvim_create_augroup(name, { clear = clear })
    return ret
end

function M:AddCmd(events, opts)
    opts = opts or {}
    opts.group = self.group
    vim.api.nvim_create_autocmd(events, opts)
end

function M:Emit(events, opts)
    opts = opts or {}
    opts.group = self.group
    vim.api.nvim_exec_autocmds(events, opts)
end

function M:Clear(opts)
    opts = opts or {}
    opts.group = self.group
    vim.api.nvim_clear_autocmds(opts)
end

return M
