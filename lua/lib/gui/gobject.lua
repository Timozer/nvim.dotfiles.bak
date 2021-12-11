require('lib.functions')
require('lib.gui.common')
require('lib.gui.tools.rect')
require('lib.gui.tools.point')
require('lib.gui.tools.size')

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

    self.parent = self:__DetectParent(self.relative, parent)

    -- geometry format:
    --     1. geometry = 0.5 ==> { x = 0.5, y = 0.5, width = 0.5, height = 0.5 }
    --     2. geometry = { position = 0.5, size = 0.8 } == > { x = 0.5, y = 0.5, width = 0.8, height = 0.8 }
    --     3. geometry = { x = 0.5, y = 0.5, width = 0.5, height = 0.5 }
    self.geometry = opts.geometry or 0.5

    self.bufopts = opts.bufopts or {}
    self.winopts = opts.winopts or {}
end

function GObject:__DetectParent(relative, parent)
    if not parent then
        if relative == GObject.RELATIVE_EDITOR then
            return 'editor'
        elseif relative == GObject.RELATIVE_WIN or relative == GObject.RELATIVE_CURSOR then
            return vim.fn.win_getid()
        else
            assert(false, "unkown window's relative")
        end
    elseif type(parent) == 'number' and not vim.api.nvim_win_is_valid(parent) or
        type(parent) == 'table' and not instanceof(parent, 'GObject') then
        assert(false, "invalid parent")
    end
    return parent
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

function GObject:__SetupGeometry()
end

function GObject:Geometry()
    return self.geometry
end

function GObject:SetGeometry(geometry)
    assert(instanceof(geometry, 'Rect'), 'invalid geometry')
    self.geometry = geometry
end

function GObject:ParentGeometry()
    if type(self.parent) == 'string' then
        assert(self.parent == 'editor', string.format('invalid parent [%s]', self.parent))
        return Rect.new(Point.new(0, 0), GetEditorSize())
    end

    if type(self.parent) == 'table' and instanceof(self.parent, 'GObject') then
        return self.parent:Geometry()
    end

    assert(vim.api.nvim_win_is_valid(self.parent), "invalid parent")
    pos = vim.api.nvim_win_get_position(parent)
    return Rect.new(Point.new(pos[2], pos[1]), GetWindowSize(self.parent))
end
