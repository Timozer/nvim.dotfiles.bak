
local M = {}
M.__index = M

function M.New(opts)

    local buf = setmetatable(opts or {}, M)
    buf.bufnr = vim.api.nvim_create_buf(false, false)

    if buf.name then
        vim.api.nvim_buf_set_name(buf.bufnr, buf.name)
    end

    if buf.opts then
        buf.SetOpts(buf.opts)
    end

    if buf.keymaps then
        buf.SetKeymaps(buf.keymaps)
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
        opts = {}, -- nowait, silent, script, expr, unique
    }
}

function M:SetKeymaps(maps)
    if not self.bufnr or not vim.api.nvim_buf_is_valid(self.bufnr) then
        return
    end
    maps = maps or {}

    for _, val in ipairs(maps) do
        vim.api.nvim_buf_set_keymap(self.bufnr, val.mode, val.lhs, val.rhs, val.opts)
    end
end

return M
