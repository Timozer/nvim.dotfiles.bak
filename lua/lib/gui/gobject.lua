require('lib.functions')
require('lib.number')
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
    --     1. geometry = '0.5' ==> { x = '0.5', y = '0.5', width = '0.5', height = '0.5' }
    --     2. geometry = { position = '0.5', size = '0.8' } == > { x = 0.5, y = 0.5, width = 0.8, height = 0.8 }
    --     3. geometry = { x = '1.0', y = '0.5', width = '0.5', height = '0.5' }
    --     4. geometry = '1'
    --     5. geometry = { position = '80', size = '8' }
    --     6. geometry = { x = '1', y = '5', width = '5', height = '5' }
    --     '1.0' represent 100%
    --     { '1.0' }
    --     { '1.0', '1.0' }
    --     { '1.0', '1.0', '1.0', '1.0' }
    --     '1' represent 1
    --     { '1' }
    --     { '1', '1' }
    --     { '1', '1', '1', '1' }
    print(dump(opts.geometry))
    self.geometry = opts.geometry or { '0.5' }
    print('cls: '..self.__cname..' '..dump(self.geometry))
    assert(type(self.geometry) == 'table', 'invalid geometry')
    for _, val in pairs(self.geometry) do
        assert(type(val) == 'string', 'invalid geometry')
    end
    self.dirty = true

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
        local geom = self:Geometry()
        print(dump(geom))
        self.winid = vim.api.nvim_open_win(
            self.bufnr,
            true,
            {
                style    = 'minimal',
                relative = self.relative,
                width    = geom.width,
                height   = geom.height,
                row      = geom.y,
                col      = geom.x,
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
    print('setup geomerty: cls: '..self.__cname..' '..dump(self.geometry))
    if not instanceof(self.geometry, 'Rect') then
        local geom = deepcopy(self.geometry)
        local n = length(geom)
        if n == 1 then
            self.geometry.x = geom[1]
            self.geometry.y = geom[1]
            self.geometry.width = geom[1]
            self.geometry.height = geom[1]
        elseif n == 2 then
            assert(geom[1] and geom[2], 'invalid geometry')
            self.geometry.x = geom[1]
            self.geometry.y = geom[1]
            self.geometry.width = geom[2]
            self.geometry.height = geom[2]
        elseif n == 4 then
            assert(geom[1] and geom[2] and geom[3] and geom[4], 'invalid geometry')
            self.geometry.x = geom[1]
            self.geometry.y = geom[2]
            self.geometry.width = geom[3]
            self.geometry.height = geom[4]
        else
            assert(false, 'invalid geometry')
        end
    end

    print('widget geom: '..dump(self.geometry))
    local pgeom = self:ParentGeometry()
    print(string.format('parent geom: x: %i y: %i width: %i height: %i',
            pgeom.x, pgeom.y, pgeom.width, pgeom.height
        ))
    if type(self.geometry.width) == 'string' then
        local width = Number.new(self.geometry.width)
        if width:IsFloat() then
            if width.value > 1 then
                width.value = 1
            end
            if width.value < 0 then
                width.value = 0
            end
            self.geometry.width = math.floor(width.value * pgeom.width)
        else
            if width.value > pgeom.width then
                width.value = pgeom.width
            end
            if width.value < 0 then
                width.value = 0
            end
            self.geometry.width = width.value
        end
    end
    if type(self.geometry.height) == 'string' then
        local height = Number.new(self.geometry.height)
        if height:IsFloat() then
            if height.value > 1 then
                height.value = 1
            end
            if height.value < 0 then
                height.value = 0
            end
            self.geometry.height = math.floor(height.value * pgeom.height)
        else
            if height.value > pgeom.height then
                height.value = pgeom.height
            end
            if height.value < 0 then
                height.value = 0
            end
            self.geometry.height = height.value
        end
    end
    if type(self.geometry.x) == 'string' then
        local x = Number.new(self.geometry.x)
        if x:IsFloat() then
            if x.value > 1 then
                x.value = 1
            end
            if x.value < 0 then
                x.value = 0
            end
            self.geometry.x = math.floor(pgeom.x + x.value * (pgeom.width - self.geometry.width))
        else
            if x.value > pgeom.width then
                x.value = pgeom.width
            end
            if x.value < 0 then
                x.value = 0
            end
            self.geometry.x = pgeom.x + x.value
        end
    end
    if type(self.geometry.y) == 'string' then
        local y = Number.new(self.geometry.y)
        if y:IsFloat() then
            if y.value > 1 then
                y.value = 1
            end
            if y.value < 0 then
                y.value = 0
            end
            self.geometry.y = math.floor(pgeom.y + y.value * (pgeom.height - self.geometry.height))
        else
            if y.value > pgeom.height then
                y.value = pgeom.height
            end
            if y.value < 0 then
                y.value = 0
            end
            self.geometry.y = pgeom.y + y.value
        end
    end

    if self.layout then
        -- TODO:
    end

    self.dirty = false
end

function GObject:Geometry()
    if self.dirty then
        self:__SetupGeometry()
    end
    return self.geometry
end

function GObject:SetGeometry(geometry)
    assert(instanceof(geometry, 'Rect'), 'invalid geometry')
    self.geometry = geometry
    self.dirty = true
end

function GObject:ParentGeometry()
    if type(self.parent) == 'string' then
        assert(self.parent == 'editor', string.format('invalid parent [%s]', self.parent))
        return Rect.new(Point.new(0, 0), GetEditorSize())
    end

    if type(self.parent) == 'table' and instanceof(self.parent, 'GObject') then
        return self.parent:Geometry()
    end

    print(self.parent)
    assert(vim.api.nvim_win_is_valid(self.parent), "invalid parent")
    pos = vim.api.nvim_win_get_position(parent)
    return Rect.new(Point.new(pos[2], pos[1]), GetWindowSize(self.parent))
end
