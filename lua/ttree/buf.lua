local M = {}
M.__index = M

function M.New(opts)

    local buf = setmetatable(opts or {}, M)
    buf.bufnr = vim.api.nvim_create_buf(false, false)

    if buf.name then
        vim.api.nvim_buf_set_name(buf.bufnr, buf.name)
    end

    if buf.opts then
        buf:SetOpts(buf.opts)
    end

    if buf.keymaps then
        buf:SetKeymaps(buf.keymaps)
    end

    return buf
end

function M:SetOpts(opts)
    if not self.bufnr or not vim.api.nvim_buf_is_valid(self.bufnr) then
        return
    end
    opts = opts or {}

    for key, val in pairs(opts) do
        vim.api.nvim_buf_set_option(self.bufnr, key, val)
    end
end

local maps = {
    {
        mode = "", -- n, i, v, x, !
        lhs = "",
        rhs = "",
        opts = {}, -- nowait, silent, script, expr, unique, callback, desc
    }
}
-- keymap example:
-- {
--     mode = 'n',
--     lhs = '<CR>',
--     rhs = '',
--     opts = { 
--         callback = require('ttree.actions').CR,
--         desc = 'CR Action' 
--     }
-- }

function M:SetKeymaps(maps)
    if not self.bufnr or not vim.api.nvim_buf_is_valid(self.bufnr) then
        return
    end
    maps = maps or {}
    for _, val in ipairs(maps) do
        vim.api.nvim_buf_set_keymap(self.bufnr, val.mode, val.lhs, val.rhs, val.opts)
    end
end

function M.GetByFileName(fname)
    local buf = setmetatable({}, M)
    buf.name = fname

    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_get_name(bufnr) == buf.name then
            buf.bufnr = bufnr
            return buf
        end
    end

    return nil
end

function M:IsLoaded()
    return self.bufnr and 
        vim.api.nvim_buf_is_valid(self.bufnr) and 
        vim.api.nvim_buf_is_loaded(self.bufnr)
end

return M
