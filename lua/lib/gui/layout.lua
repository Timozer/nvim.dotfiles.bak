local class = require('lib.class').class

LayoutItem = class('LayoutItem')

function LayoutItem.new(...)
    assert(false, 'abstract class cannot be instanced')
end

function LayoutItem:ctor()
end

function LayoutItem:Geometry()
    assert(false, 'pure virtual method called')
end

function LayoutItem:SetGeometry()
    assert(false, 'pure virtual method called')
end

function LayoutItem:Layout()
    assert(false, 'pure virtual method called')
end

function LayoutItem:Widget()
    assert(false, 'pure virtual method called')
end

function LayoutItem:SizeHint()
    assert(false, 'pure virtual method called')
end

function LayoutItem:IsEmpty()
    assert(false, 'pure virtual method called')
end

Layout = class('Layout', LayoutItem)

function Layout.new(...)
    assert(false, 'abstract class cannot be instanced')
end

function Layout:ctor(parent)
    if parent and  instanceof(parent, 'Widget') then
        parent:SetLayout(self)
    end
    self.parent = parent
    self.spacing = 0
end

function Layout:ParentWidget()
    if parent and instanceof(parent, 'Layout') then
        return parent:ParentWidget()
    end
    return parent
end

function Layout:AddChildLayout(layout)
    assert(not layout.parent, 'layout already has a parent')
    layout.parent = self
    parentWidget = self:ParentWidget()
    if parentWidget then
        layout:ReparentChildWidgets(parentWidget)
    end
end

function Layout:ReparentChildWidgets(parent)
end

function Layout:AddItem(item)
    assert(false, 'pure virtual method called')
end

function Layout:AddWidget(widget)
end

function Layout:ItemAt(idx)
    assert(false, 'pure virtual method called')
end

function Layout:TakeAt(idx)
    assert(false, 'pure virtual method called')
end

function Layout:RemoveItem(item)
end

function Layout:RemoveWidget(widget)
end

function Layout:Count()
    assert(false, 'pure virtual method called')
end

function Layout:Spacing()
    return self.spacing
end

function Layout:SetSpacing(spacing)
    self.spacing = spacing
end

function Layout:IsEmpty()
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

BoxLayout = class('BoxLayout', Layout)

BoxLayout.DIRECTION_HORIZONTAL = 'horizontal'
BoxLayout.DIRECTION_VERTICAL = 'vertical'

function BoxLayout:ctor(direction, parent)
    self.super:ctor(parent)
    self.direction = direction
end


HBoxLayout = class('HBoxLayout', Layout)

function HBoxLayout:ctor(parent)
    self.super:ctor(parent)
end

VBoxLayout = class('VBoxLayout', Layout)
function VBoxLayout:ctor(parent)
    self.super:ctor(parent)
end

return hbox
