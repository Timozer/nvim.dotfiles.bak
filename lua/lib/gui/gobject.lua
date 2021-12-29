require('lib.functions')
require('lib.gui.common')
require('lib.gui.tools')

require('PLoop')

PLoop(function(_ENV)
    namespace "gui"

    __Abstract__()
    class "GObject" (function(_ENV)
        __Sealed__()
        enum "Relative" { Editor = 'editor', Win = 'win', Cursor = 'cursor' }

        function GObject(self, opts, parent)
            self.bufnr = -1
            self.winid = -1

            self.relative = opts.relative or GObject.Relative.Editor

            self.parent = DetectParent(self.relative, parent)

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
            self.geometry = opts.geometry or { '0.5' }
            assert(type(self.geometry) == 'table', 'invalid geometry')
            for _, val in pairs(self.geometry) do
                assert(type(val) == 'string', 'invalid geometry')
            end
            self.dirty = true

            self.bufopts = opts.bufopts or {}
            self.winopts = opts.winopts or {}
        end

        __Static__()
        function DetectParent(relative, parent)
            if not parent then
                if relative == Relative.Editor then
                    return 'editor'
                elseif relative == Relative.Win or relative == Relative.Cursor then
                    return vim.fn.win_getid()
                else
                    assert(false, "unkown window's relative")
                end
            elseif type(parent) == 'number' and not vim.api.nvim_win_is_valid(parent) or
                type(parent) == 'table' and not Class.IsSubType(parent, GObject) then
                assert(false, "invalid parent")
            end
            return parent
        end

        function Create(self)
            if self.bufnr < 1 then
                self.bufnr = vim.api.nvim_create_buf(false, true)
                assert(self.bufnr, 'failed to create buffer')
                Common.SetBufOptions(self.bufnr, self.bufopts)
            end
            if self.winid < 1 then
                local geom = self:Geometry()
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
                Common.SetWinOptions(self.winid, self.winopts)
            end
        end

        function Dispose(self)
            -- local bufnr = vim.api.nvim_win_get_buf(self.winid)
            -- -- only delete the window's buffer
            -- if self.bufnr ~= bufnr then
            --     -- TODO: warn
            -- end
            Common.DestoryBuffer(self.bufnr, force)
            self.bufnr = nil
            Common.DestoryWindow(self.winid, true)
            self.winid = nil
        end

        __Abstract__()
        function Show(self)
        end

        function __SetupGeometry(self)
            if not Class.IsSubType(self.geometry, Rect) then
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

            local pgeom = self:ParentGeometry()
            if type(self.geometry.width) == 'string' then
                local width = StringNumber(self.geometry.width)
                if width:IsFloat() then
                    if width.Value > 1 then
                        width.Value = 1
                    end
                    if width.Value < 0 then
                        width.Value = 0
                    end
                    self.geometry.width = math.floor(width.Value * pgeom.width)
                else
                    if width.Value > pgeom.width then
                        width.Value = pgeom.width
                    end
                    if width.Value < 0 then
                        width.Value = 0
                    end
                    self.geometry.width = width.Value
                end
            end
            if type(self.geometry.height) == 'string' then
                local height = StringNumber(self.geometry.height)
                if height:IsFloat() then
                    if height.Value > 1 then
                        height.Value = 1
                    end
                    if height.Value < 0 then
                        height.Value = 0
                    end
                    self.geometry.height = math.floor(height.Value * pgeom.height)
                else
                    if height.Value > pgeom.height then
                        height.Value = pgeom.height
                    end
                    if height.Value < 0 then
                        height.Value = 0
                    end
                    self.geometry.height = height.Value
                end
            end
            if type(self.geometry.x) == 'string' then
                local x = StringNumber(self.geometry.x)
                if x:IsFloat() then
                    if x.Value > 1 then
                        x.Value = 1
                    end
                    if x.Value < 0 then
                        x.Value = 0
                    end
                    self.geometry.x = math.floor(pgeom.x + x.Value * (pgeom.width - self.geometry.width))
                else
                    if x.Value > pgeom.width then
                        x.Value = pgeom.width
                    end
                    if x.Value < 0 then
                        x.Value = 0
                    end
                    self.geometry.x = pgeom.x + x.Value
                end
            end
            if type(self.geometry.y) == 'string' then
                local y = StringNumber(self.geometry.y)
                if y:IsFloat() then
                    if y.Value > 1 then
                        y.Value = 1
                    end
                    if y.Value < 0 then
                        y.Value = 0
                    end
                    self.geometry.y = math.floor(pgeom.y + y.Value * (pgeom.height - self.geometry.height))
                else
                    if y.Value > pgeom.height then
                        y.Value = pgeom.height
                    end
                    if y.Value < 0 then
                        y.Value = 0
                    end
                    self.geometry.y = pgeom.y + y.Value
                end
            end

            if self.layout then
                -- TODO:
            end

            self.dirty = false
        end

        function Geometry(self)
            if self.dirty then
                self:__SetupGeometry()
            end
            return self.geometry
        end

        function SetGeometry(self, geometry)
            assert(Class.IsSubType(geometry, Rect), 'invalid geometry')
            self.geometry = geometry
            self.dirty = true
        end

        function ParentGeometry(self)
            if type(self.parent) == 'string' then
                assert(self.parent == 'editor', string.format('invalid parent [%s]', self.parent))
                return Rect(Point(0, 0), Common.GetEditorSize())
            end

            if type(self.parent) == 'table' and Class.IsSubType(self.parent, GObject) then
                return self.parent:Geometry()
            end

            assert(vim.api.nvim_win_is_valid(self.parent), "invalid parent")
            pos = vim.api.nvim_win_get_position(parent)
            return Rect(Point(pos[2], pos[1]), Common.GetWindowSize(self.parent))
        end
    end)


end)
