require('lib.functions')
require('lib.gui.tools.size')

function GetEditorSize()
    return Size.new(vim.o.columns, vim.o.lines)
end

function GetWindowSize(winid)
    if not win or not vim.api.nvim_win_is_valid(buf) then
        return Size.INVALID_SIZE
    end
    return Size.new(
        vim.api.nvim_win_get_width(winid),
        vim.api.nvim_win_get_height(winid)
    )
end

function SetBufOptions(buf, opts)
    if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return
    end
    for key, val in pairs(opts) do
        vim.api.nvim_buf_set_option(buf, key, val)
    end
end

function SetWinOptions(win, opts)
    if not win or not vim.api.nvim_win_is_valid(buf) then
        return
    end
    for key, val in pairs(opts) do
        vim.api.nvim_win_set_option(win, key, val)
    end
end

function DestoryBuffer(bufnr, force)
    if not bufnr then
        return
    end

    -- Suppress the buffer deleted message for those with &report<2
    local start_report = vim.o.report
    if start_report < 2 then
        vim.o.report = 2
    end

    if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
        vim.api.nvim_buf_delete(bufnr, { force = force })
    end

    if start_report < 2 then
        vim.o.report = start_report
    end
end

function DestoryWindow(winid, force)
    if not winid or not vim.api.nvim_win_is_valid(winid) then
        return
    end

    if not pcall(vim.api.nvim_win_close, winid, force) then
        log.trace("Unable to close window: ", name, "/", win_id)
    end
end

