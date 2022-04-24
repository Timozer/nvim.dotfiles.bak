
local M = {
    prev_focused_win = nil,
    tabs = {},
    highlight_namespace = vim.api.nvim_create_namespace("TTreeHighlights"),
}

local BUFFER_OPTIONS = {
  swapfile = false,
  buftype = "nofile",
  modifiable = false,
  filetype = "TTree",
  bufhidden = "wipe",
  buflisted = false,
}

local WIN_OPTIONS = {
    relativenumber = false,
    number = false,
    list = false,
    foldenable = false,
    winfixwidth = true,
    winfixheight = true,
    spell = false,
    signcolumn = "yes",
    foldmethod = "manual",
    foldcolumn = "0",
    cursorcolumn = false,
    cursorlineopt = "line",
    colorcolumn = "0",
    wrap = false,
    winhl = table.concat({
        "EndOfBuffer:TTreeEndOfBuffer",
        "Normal:TTreeNormal",
        "CursorLine:TTreeCursorLine",
        "VertSplit:TTreeVertSplit",
        "StatusLine:TTreeStatusLine",
        "StatusLineNC:TTreeStatuslineNC",
        "SignColumn:TTreeSignColumn",
        "NormalNC:TTreeNormalNC",
    }, ","),
}

local function SetBufOpts(bufnr, opts)
    if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return
    end
    for key, val in pairs(opts) do
        vim.api.nvim_buf_set_option(buf, key, val)
    end
end

local function SetBufKeybindings(bufnr, keybindings)
    return
end

local function CreateBuffer(name, opts, keybindings)
    local bufnr = vim.api.nvim_create_buf(false, false)
    assert(bufnr, 'failed to create buffer')

    if name then
        vim.api.nvim_buf_set_name(bufnr, "TTree_")
    end

    SetBufOpts(bufnr, opts or {})
    SetBufKeybindings(bufnr, keybindings or {})

    return bufnr
end

local function SetWinOpts(winnr, opts)
    if not winnr or not vim.api.nvim_win_is_valid(winnr) then
        return
    end
    for key, val in pairs(opts) do
        vim.api.nvim_win_set_option(winnr, key, val)
    end
end

local function CreateWindow(bufnr)
    vim.api.nvim_command("vsp")
    vim.api.nvim_command("wincmd H")
    local winnr = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(winnr, bufnr)

    SetWinOpts(winnr, WIN_OPTIONS)
    vim.api.nvim_win_set_width(winnr, 20)
    return winnr
end

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
        M.tabs[tabpage].bufnr = CreateBuffer("TTree_" .. tabpage, BUFFER_OPTIONS)
    end

    if not M.tabs[tabpage].winnr or not vim.api.nvim_win_is_valid(M.tabs[tabpage].winnr) then
        M.tabs[tabpage].winnr = CreateWindow(M.tabs[tabpage].bufnr)
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
