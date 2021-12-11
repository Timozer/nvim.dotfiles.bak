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

function CalcWinSize(size, parent_size)
    if type(size) ~= "table" then
        size = { width = size, height = size, }
    end

    local width = ToNumber(size.width)
    assert(width, 'invalid size.width')
    if math.floor(width) < width then
        if width > 1 then
            width = 1
        end
        width = math.floor(width * parent_size.width)
    elseif width > parent_size.width then
        width = parent_size.width
    end

    local height = ToNumber(size.height)
    assert(height, 'invalid size.height')
    if math.floor(height) < height then
        if height > 1 then
            height = 1
        end
        height = math.floor(height * parent_size.height)
    elseif height > parent_size.height then
        height = parent_size.height
    end

    return { width = width, height = height, }
end

function CalcWinPos(pos, parent_pos, win_size, parent_size)
    if type(pos) ~= 'table' then
        pos = { row = pos, col = pos, }
    end

    local row = ToNumber(pos.row)
    assert(row, 'invalid pos.row')
    if math.floor(row) < row then
        if row > 1 then
            row = 1
        end
        row = math.floor(row * (parent_size.height - win_size.height))
    end

    local col = ToNumber(pos.col)
    assert(col, 'invalid pos.col')
    if math.floor(col) < col then
        if col > 1 then
            col = 1
        end
        col = math.floor(col * (parent_size.width - win_size.width))
    end

    return { row = row + parent_pos.row, col = col + parent_pos.col, }
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

