require('PLoop')
require('lib.functions')
require('lib.gui.gobject')
-- require('lib.gui.layout')
--
PLoop(function(_ENV)
    namespace "gui"

--     class "WidgetItem" (function(_ENV)
--         inherit "LayoutItem"

--         function WidgetItem(self, widget)
--             assert(Class.IsSubType(widget, 'Widget'), 'invalid widget')
--             self.widget = widget
--         end
--         function SizeHint(self)
--             assert(false, 'pure virtual method called')
--         end

--         function MinimumSize(self)
--             assert(false, 'pure virtual method called')
--         end

--         function MaximumSize(self)
--             assert(false, 'pure virtual method called')
--         end
--         function Geometry(self)
--             assert(false, 'pure virtual method called')
--         end
--         function SetGeometry(self)
--             assert(false, 'pure virtual method called')
--         end
--         function Widget(self)
--             return self.widget
--         end

--         function IsEmpty(self)
--             return not self.widget or self.widget:IsHidden() 
--         end
--     end)

    class "Widget" (function(_ENV)
        inherit "GObject"

        function Widget(self, opts, parent)
            super(self, opts, parent)

            self.bufopts = opts.bufopts or {
                buflisted = false,
                modifiable = false,
                readonly = true,
            }

            self.enter = opts.enter or true

            self.border = nil
            self.border = Border(self, {style = opts.border or Border.Style.None})

            self.child_widgets = List()
        end

        function SetGeometry(self, geometry)
            super[self]:SetGeometry(geometry)
            if self.border then
                self.border.dirty = true
            end
        end

        function Show(self)
            if self.border then
                self.border:Show()
            end

            self:Create()

            for _, child in ipairs(self.child_widgets) do
                child:Show()
            end
        end

--         function Widget:Layout()
--             return self.layout
--         end

--         function Widget:SetLayout(layout)
--             self.layout = layout
--         end

--         function AddWidget(child)
--             table.insert(self.child_widgets, child)
--         end

--         function SetParent(parent)
--             self.parent = parent
--         end
    end)

end)
