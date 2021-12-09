require('lib.functions')
require('lib.gui.common')

GObject = class('GObject')

GObject.RELATIVE_EDITOR = 'editor'
GObject.RELATIVE_WIN    = 'win'
GObject.RELATIVE_CURSOR = 'cursor'

function GObject.new(...)
    assert(false, 'abstract class cannot be instanced')
end

function GObject:ctor(opts, parent)
    self.bufnr = -1
    self.winid = -1

    self.relative = opts.relative or GObject.RELATIVE_EDITOR

    if not parent then
        if self.relative == GObject.RELATIVE_EDITOR then
            parent = 'editor'
        elseif self.relative == GObject.RELATIVE_WIN or self.relative == GObject.RELATIVE_CURSOR then
            parent = 0
        else
            assert(false, "unkown window's relative")
        end
    elseif type(parent) == 'number' and not vim.api.nvim_win_is_valid(parent) or
        type(parent) == 'table' and not instanceof(parent, 'GObject') then
        assert(false, "invalid parent")
    end

    info = GetParentInfo(parent)

    -- size format:
    --     1. size = '80%'
    --     2. size = { width = '80%', height = '80%' }
    --     3. size = 80
    --     4. size = { width = 80, height = 80 }
    self.size = CalcWinSize(opts.size or '50%', info.size)
    -- pos format, pos is the window's center:
    --     1. pos = '50%'
    --     2. pos = { row = '80%', col = '80%' }
    --     3. pos = 50
    --     4. pos = { row = 50, col = 50 }
    self.pos  = CalcWinPos(opts.pos or '50%', info.pos, self.size, info.size)

    self.bufopts = opts.bufopts or {}
    self.winopts = opts.winopts or {}
end

function GObject:Create()
    if self.bufnr < 1 then
        self.bufnr = vim.api.nvim_create_buf(false, true)
        assert(self.bufnr, 'failed to create buffer')
        SetBufOptions(self.bufnr, self.bufopts)
    end
    if self.winid < 1 then
        self.winid = vim.api.nvim_open_win(
            self.bufnr,
            true,
            {
                style    = 'minimal',
                relative = self.relative,
                width    = self.size.width,
                height   = self.size.height,
                row      = self.pos.row,
                col      = self.pos.col,
            }
        )
        assert(self.winid, 'failed to create window')
        SetWinOptions(self.winid, self.winopts)
    end
end

function GObject:Destory()
    -- local bufnr = vim.api.nvim_win_get_buf(self.winid)
    -- -- only delete the window's buffer
    -- if self.bufnr ~= bufnr then
    --     -- TODO: warn
    -- end
    DestoryBuffer(self.bufnr, force)
    self.bufnr = nil
    DestoryWindow(self.winid, true)
    self.winid = nil
end

function GObject:Show()
    assert(false, 'should be overwrite by sub class')
end

function GObject:Width()
    return self.size.width
end

function GObject:Height()
    return self.size.height
end
