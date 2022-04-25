
local M = {}

function M.New(opts)
    local win = setmetatable(opts or {}, M)
    vim.api.nvim_command("vsp")
    vim.api.nvim_command("wincmd H")
    local winnr = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(winnr, bufnr)

    if win.width and win.width > 0 then
        vim.api.nvim_win_set_width(winnr, 20)
    end
    return winnr
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
