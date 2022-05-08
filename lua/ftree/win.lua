
local M = {}
M.__index = M

function M.NewFloat(opts)
end

function M.New(opts)
    local win = setmetatable(opts or {}, M)
    vim.api.nvim_command("vsp")
    vim.api.nvim_command("wincmd H")
    win.winnr = vim.api.nvim_get_current_win()

    if win.bufnr then
        vim.api.nvim_win_set_buf(win.winnr, win.bufnr)
    end

    if win.width and win.width > 0 then
        vim.api.nvim_win_set_width(win.winnr, win.width)
    end

    if win.opts then
        win:SetOpts(win.opts)
    end
    return win
end

function M:SetOpts(opts)
    if not self.winnr or not vim.api.nvim_win_is_valid(self.winnr) then
        return
    end
    opts = opts or {}
    for key, val in pairs(opts) do
        vim.api.nvim_win_set_option(self.winnr, key, val)
    end
end


return M
