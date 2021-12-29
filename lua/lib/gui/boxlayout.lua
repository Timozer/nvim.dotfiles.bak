require('lib.functions')
require('lib.gui.layout')
require('PLoop')

PLoop(function(_ENV)
    namespace "gui"

    class "BoxLayout" (function(_ENV)
        inherit "Layout"

        __Sealed__()
        enum "Direct" {
            Horizontal = 'horizontal',
            Vertical = 'vertical',
            Left2Right = 'l2r',
            Right2Left = 'r2l',
            Top2Bottom = 't2b',
            Bottom2Top = 'b2t',
        }

        field {
        }

        property "Direction" { type = String }

        __Static__()
        function horz(dir)
            return dir == Direct.LeftToRight or dir == Direct.RightToLeft
        end

        function BoxLayout(self, direction, parent)
            super(self, parent)
            self.Direction = direction or Direct.LeftToRight
            self.items = List()
        end

        function setupGemo(self)
            local maxw = 1000
            local maxh = 1000
            if BoxLayout.horz(self.Direction) then
                maxw = 0
            else
                maxh = 0
            end
            local minw = 0
            local minh = 0
            local hintw = 0
            local hinth = 0

            local nitems = self.items:size()
            local spacing = self:Spacing()

            i = 1
            while i < nitems do
                i = i + 1
            end
        end

        function SetGeometry(self, geometry)
            self.super:SetGeometry(geometry)
        end
    end)
end)

