local vapi = require('lib.api')

local M = {}
M.__index = M

function M.New(win)
    win = win or 0
    local ret = setmetatable({win = win}, M)
    if win == -1 then
        ret.row = vim.o.lines - (vim.api.nvim_get_option('cmdheight') or 1) + 1
        ret.col = vim.fn.getcmdpos() - 1
    else
        local cursor = vim.api.nvim_win_get_cursor(win)
        ret.row = cursor[1] - 1
        ret.col = cursor[2] - 1
    end
    return ret
end

function M:GetWholeLine()
    if self.win == -1 then
        return vim.fn.getcmdline()
    end
    buf = vim.api.nvim_win_get_buf(self.win)
    return vim.api.nvim_buf_get_lines(buf, self.row, self.row + 1, false)[1]
end

function M:GetLineBefore()
    local line = self:GetWholeLine()
    return string.sub(line, 1, self.col + 1)
end

return M
