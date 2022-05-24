local buf = require('lib.buf')
local M = {}
M.__index = M

-- local config = {
--     relative = 'editor' | 'win' | 'cursor' | '',
--     win = winid,
--     anchor = 'NW' | 'NE' | 'SW' | 'SE',
--     width = 0,
--     height = 0,
--     row = 0,
--     col = 0,
--     focusable = true,
--     zindex = 100,
--     border = 'rounded',
--     noautocmd = false,
-- }

function M.New(opts)
    opts = opts or {}
    local w = setmetatable({}, M)
    w.name = opts.name
    w.winid = nil
    w.winnr = nil
    w.enter = opts.enter or false
    w.config = opts.config or { relative = 'cursor', width = 1, height = 1}
    w.options = opts.options or {}
    w.buffer = opts.buffer
    return w
end

function M:GetOption(key)
    if vim.fn.exists('+'..key) == 0 then
        return nil
    end
    if not self:Visible() then
        return self.options[key]
    else
        return vim.api.nvim_win_get_option(self.winid, key)
    end
end

function M:SetOption(key, val)
    if vim.fn.exists('+'..key) == 0 or val == nil then
        return
    end

    self.options[key] = val
    if self:Visible() then
        vim.api.nvim_win_set_option(self.winid, key, val)
    end
end

function M:SetOptions(opts)
    for k, v in pairs(opts) do
        self:SetOption(k, v)
    end
end

function M:Visible()
    return self.winid and vim.api.nvim_win_is_valid(self.winid)
end

function M:Open()
    if self:Visible() then
        return
    end

    if self.config.width < 1 or self.config.height < 1 then
        return
    end

    if not self.buffer:Valid() then
        self.buffer = buf.New()
    end

    self.winid = vim.api.nvim_open_win(self.buffer.bufnr, self.enter, self.config)
    self:SetOptions(self.options)
    self:Update()
end

function M:Update()
    if not self:Visible() then
        return
    end

    vim.api.nvim_win_set_config(self.winid, self.config)
end

function M:Close()
    if not self:Visible() then
        return
    end
    vim.api.nvim_win_hide(self.winid)
    self.winid = nil
end

local testWin = M.New({
    name = 'TestWin',
    enter = true,
    config = {
        relative = 'cursor',
        width = 8,
        height = 8,
        row = 1,
        col = 1,
        border = 'rounded'
    },
    options = {
    }
})
testWin:Open()


return M
