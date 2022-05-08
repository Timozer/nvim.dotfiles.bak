local M = {
    prev_focused_win = nil,
    tabs = {},
    highlight_namespace = vim.api.nvim_create_namespace("FTreeHighlights"),
}

function M.Open(opts)
    if M.Visable() then
        return
    end

    M.prev_focused_win = vim.api.nvim_get_current_win()

    local tabpage = vim.api.nvim_get_current_tabpage()
    if not M.tabs[tabpage] then
        M.tabs[tabpage] = {}
    end

    if not M.tabs[tabpage].buf or
        not M.tabs[tabpage].buf.bufnr or
        not vim.api.nvim_buf_is_valid(M.tabs[tabpage].buf.bufnr) then
        M.tabs[tabpage].buf = require("ftree.buf").New({
                name = "FTree_" .. tabpage,
                opts = {
                    swapfile   = false,
                    buftype    = "nofile",
                    modifiable = false,
                    filetype   = "FTree",
                    bufhidden  = "hide",
                    buflisted  = false,
                },
            })
    end

    if not M.tabs[tabpage].winnr or not vim.api.nvim_win_is_valid(M.tabs[tabpage].winnr) then
        local window = require("ftree.win").New({
            bufnr = M.tabs[tabpage].buf.bufnr,
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
        M.tabs[tabpage].win = window
        M.RestoreState()
    end

end

function M.GetWinnr()
    if M.tabs then
        local tabpage = vim.api.nvim_get_current_tabpage()
        if M.tabs[tabpage] and M.tabs[tabpage].win then
            return M.tabs[tabpage].win.winnr
        end
    end
    return nil
end

function M.Visable()
    local tabpage = vim.api.nvim_get_current_tabpage()
    return M.tabs[tabpage] and M.tabs[tabpage].winnr ~= nil and vim.api.nvim_win_is_valid(M.tabs[tabpage].winnr)
end

-- Update view buffer lines, highlights and keymaps
function M.Update(lines, highlights, keymaps)
    local tabpage = vim.api.nvim_get_current_tabpage()
    local buf = M.tabs[tabpage].buf
    if not buf or not buf.bufnr or not vim.api.nvim_buf_is_loaded(buf.bufnr) then
        return
    end

    vim.api.nvim_buf_set_option(buf.bufnr, "modifiable", true)
    vim.api.nvim_buf_set_lines(buf.bufnr, 0, -1, false, lines)
    vim.api.nvim_buf_clear_namespace(buf.bufnr, M.highlight_namespace, 0, -1)
    for _, data in ipairs(highlights) do
        vim.api.nvim_buf_add_highlight(buf.bufnr, M.highlight_namespace, data[1], data[2], data[3], data[4])
    end
    vim.api.nvim_buf_set_option(buf.bufnr, "modifiable", false)

    buf:SetKeymaps(keymaps)
end

function M.GetCursor()
    local tabpage = vim.api.nvim_get_current_tabpage()
    return M.tabs[tabpage] and
        M.tabs[tabpage].winnr ~= nil and
        vim.api.nvim_win_is_valid(M.tabs[tabpage].winnr) and
        vim.api.nvim_win_get_cursor(M.tabs[tabpage].winnr)
end

function M.SetCursor(cursor)
    if not M.Visable() then
        return
    end
    local tabpage = vim.api.nvim_get_current_tabpage()
    vim.api.nvim_win_set_cursor(M.tabs[tabpage].winnr, cursor)
end

function M.SaveState()
    local tabpage = vim.api.nvim_get_current_tabpage()
    M.tabs[tabpage].cursor = M.GetCursor()
end

function M.RestoreState()
    local tabpage = vim.api.nvim_get_current_tabpage()
    if M.tabs[tabpage].cursor then
        vim.api.nvim_win_set_cursor(M.tabs[tabpage].win.winnr, M.tabs[tabpage].cursor)
    end
end

function M.Close()
    M.SaveState()
    local tabpage = vim.api.nvim_get_current_tabpage()
    vim.api.nvim_win_close(M.tabs[tabpage].win.winnr, true)
end

function M.GetSign(lnum)
    if not M.Visable() then
        return
    end

    local tabpage = vim.api.nvim_get_current_tabpage()
    return vim.fn.sign_getplaced(M.tabs[tabpage].buf.bufnr, {
        group = "FTreeView",
        lnum = lnum,
    })
end

function M.SetSign(name, lnum)
    if not M.Visable() then
        return
    end
    local tabpage = vim.api.nvim_get_current_tabpage()
    local id = vim.fn.sign_place(lnum, "FTreeView", name, M.tabs[tabpage].buf.bufnr, {lnum = lnum})
end

function M.ClearSign(id)
    if not M.Visable() then
        return
    end
    local tabpage = vim.api.nvim_get_current_tabpage()
    vim.fn.sign_unplace("FTreeView", { buffer = M.tabs[tabpage].buf.bufnr, id = id })
end

return M
