
local M = {
    prev_focused_win = nil,
    tabs = {},
    highlight_namespace = vim.api.nvim_create_namespace("TTreeHighlights"),
}

function M.Open()
    if M.Visable() then
        return
    end

    M.prev_focused_win = vim.api.nvim_get_current_win()

    local tabpage = vim.api.nvim_get_current_tabpage()
    if not M.tabs[tabpage] then
        M.tabs[tabpage] = {}
    end

    if not M.tabs[tabpage].bufnr or not vim.api.nvim_buf_is_valid(M.tabs[tabpage].bufnr) then
        local buf = require("ttree.buf").New({
                name = "TTree_" .. tabpage,
                opts = {
                    swapfile   = false,
                    buftype    = "nofile",
                    modifiable = false,
                    filetype   = "TTree",
                    bufhidden  = "wipe",
                    buflisted  = false,
                },
                keymaps = {
                }
            })
        M.tabs[tabpage].bufnr = buf.bufnr
    end

    if not M.tabs[tabpage].winnr or not vim.api.nvim_win_is_valid(M.tabs[tabpage].winnr) then
        local window = require("ttree.win").New({
            bufnr = M.tabs[tabpage].bufnr,
            width = 20,
            opts = {
                relativenumber = false,
                number         = false,
                list           = false,
                foldenable     = false,
                winfixwidth    = true,
                winfixheight   = true,
                spell          = false,
                signcolumn     = "yes",
                foldmethod     = "manual",
                foldcolumn     = "0",
                cursorcolumn   = false,
                cursorlineopt  = "line",
                colorcolumn    = "0",
                wrap           = false,
            }
        })
        M.tabs[tabpage].winnr = window.winnr
    end

end

function M.Visable()
    local tabpage = vim.api.nvim_get_current_tabpage()
    return M.tabs[tabpage] and M.tabs[tabpage].winnr ~= nil and vim.api.nvim_win_is_valid(M.tabs[tabpage].winnr)
end

function M.Update(lines, highlights)
    local tabpage = vim.api.nvim_get_current_tabpage()
    local bufnr = M.tabs[tabpage].bufnr
    if not bufnr or not vim.api.nvim_buf_is_loaded(bufnr) then
        return
    end

    vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.api.nvim_buf_clear_namespace(bufnr, M.highlight_namespace, 0, -1)
    for _, data in ipairs(highlights) do
        vim.api.nvim_buf_add_highlight(bufnr, M.highlight_namespace, data[1], data[2], data[3], data[4])
    end
    vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
end

return M
