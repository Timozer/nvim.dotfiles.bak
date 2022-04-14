require('lib.functions')
require('lib.gui.widget')
require('PLoop')

PLoop(function(_ENV)
    namespace "gui"

    __Abstract__()
    class "LayoutItem" (function(_ENV)
        function LayoutItem(self, ...)
        end

        __Abstract__()
        function SizeHint(self)
        end

        __Abstract__()
        function MinimumSize(self)
        end

        __Abstract__()
        function MaximumSize(self)
        end

        __Abstract__()
        function Geometry(self)
        end

        __Abstract__()
        function SetGeometry(self, geom)
        end

        __Abstract__()
        function Layout(self)
            return nil
        end

        __Abstract__()
        function Widget(self)
            return nil
        end

        __Abstract__()
        function IsEmpty(self)
        end
    end)

    __Abstract__()
    class "Layout" (function(_ENV)
        inherit "LayoutItem"

        function Layout(self, parent)
            if parent and  Class.IsSubType(parent, 'Widget') then
                parent:SetLayout(self)
            end
            self.parent = parent
            self.spacing = 0
            self.geometry = { size = { width = 0, height = 0 }, pos = { row = 0, col = 0} }
        end

        function ParentWidget(self)
            if parent and Class.IsSubType(parent, 'Layout') then
                return parent:ParentWidget()
            end
            return parent
        end

        function AddChildLayout(self, layout)
            assert(not layout.parent, 'layout already has a parent')
            layout.parent = self
            parentWidget = self:ParentWidget()
            if parentWidget then
                layout:ReparentChildWidgets(parentWidget)
            end
        end

        function ReparentChildWidgets(self, parent)
        end

        __Abstract__()
        function AddItem(self, item)
        end

        __Abstract__()
        function AddWidget(self, widget)
        end

        __Abstract__()
        function ItemAt(self, idx)
        end

        __Abstract__()
        function TakeAt(self, idx)
        end

        __Abstract__()
        function RemoveItem(self, item)
        end

        __Abstract__()
        function RemoveWidget(self, widget)
        end

        __Abstract__()
        function Count(self)
        end

        function Geometry(self )
            return self.geometry
        end

        function SetGeometry(self, geometry)
            if geometry then
                self.geometry = geometry
            end
        end

        function Spacing(self)
            return self.spacing
        end

        function SetSpacing(self, spacing)
            if spacing < 0 then
                return
            end
            self.spacing = spacing
        end

        function IsEmpty(self)
            local i = 1;
            local item = self:ItemAt(i);
            while item do
                if not item:IsEmpty() then
                    return false
                end
                i = i + 1
                item = self:ItemAt(i);
            end
            return true
        end
    end)
end)

