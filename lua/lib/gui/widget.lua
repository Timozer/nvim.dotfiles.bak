require('lib.functions')
require('lib.gui.gobject')
require('lib.gui.border')
require('lib.gui.layout')

WidgetItem = class('WidgetItem', LayoutItem)

function WidgetItem:ctor(widget)
    assert(instanceof(widget, 'Widget'), 'invalid widget')
    self.widget = widget
end

function LayoutItem:SizeHint()
    assert(false, 'pure virtual method called')
end

function LayoutItem:MinimumSize()
    assert(false, 'pure virtual method called')
end

function LayoutItem:MaximumSize()
    assert(false, 'pure virtual method called')
end

function LayoutItem:Geometry()
    assert(false, 'pure virtual method called')
end

function LayoutItem:SetGeometry()
    assert(false, 'pure virtual method called')
end

function LayoutItem:Widget()
    return self.widget
end

function LayoutItem:IsEmpty()
    return not self.widget or self.widget:IsHidden() 
end

Widget = class('Widget', GObject)

local opts = {
    relative = Widget.RELATIVE_WIN,
    size = '80%',
    pos = '50%',
    bufopts = {
        buflisted = false,
        modifiable = false,
        readonly = true,
    },
    winopts = {
    },
    enter = true,
    border = Border.STYLE_ROUNDED,
}

function Widget:ctor(opts, parent)
    self.super:ctor(opts, parent)

    self.hidden = true

    self.bufopts = opts.bufopts or {
        buflisted = false,
        modifiable = false,
        readonly = true,
    }

    self.enter = opts.enter or true

    self.border = opts.border or Border.STYLE_NONE

    self.child_widgets = {}
end

function Widget:IsHidden()
    return self.hidden
end

function Widget:Show()
    if not self.hidden then
        return
    end

    if self.border then
        local border = Border.new(self, { style = self.border })
        border:Show()
    end

    self:Create()

    self.hidden = false
end

function Widget:Layout()
    return self.layout
end

function Widget:SetLayout(layout)
    self.layout = layout
end

function Widget:AddWidget(child)
    table.insert(self.child_widgets, child)
end

function Widget:SetParent(parent)
    self.parent = parent
end
