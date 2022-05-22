local M = {
    old_keymaps = {}
}
M.__index = M

function M.New(opts)

    local buf = setmetatable(opts or {}, M)
    buf.bufnr = vim.api.nvim_create_buf(false, false)

    if buf.name then
        vim.api.nvim_buf_set_name(buf.bufnr, buf.name)
    end

    if buf.opts then
        buf:SetOptions(buf.opts)
    end

    if buf.keymaps then
        buf:SetKeymaps(buf.keymaps)
    end

    return buf
end

function M:SetOption(key, val)
    if vim.fn.exists('+'..key) == 0 or val == nil then
        return
    end
    self.options[key] = val
    if self:Valid() then
        vim.api.nvim_buf_set_option(self.bufnr, key, val)
    end
end

function M:SetOptions(opts)
    if type(opts) == 'table' and #opts > 0 then
        for k, v in pairs(opts) do
            self:SetOption(k, v)
        end
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
--         callback = require('ftree.actions').CR,
--         desc = 'CR Action' 
--     }
-- }
--
function M:SetKeymaps(maps)
    if not self:Valid() then
        return
    end
    maps = maps or {}

    for _, val in ipairs(self.old_keymaps) do
        vim.api.nvim_buf_del_keymap(self.bufnr, val.mode, val.lhs)
    end

    for _, val in ipairs(maps) do
        vim.api.nvim_buf_set_keymap(self.bufnr, val.mode, val.lhs, val.rhs, val.opts)
    end

    self.old_keymaps = maps
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

function M:Loaded()
    return self:Valid() and vim.api.nvim_buf_is_loaded(self.bufnr)
end

function M:Valid()
    return self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr)
end

return M
