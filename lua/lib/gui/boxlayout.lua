require('lib.functions')
require('lib.class')
require('lib.gui.layout')

BoxLayout = class('BoxLayout', Layout)

BoxLayout.DIRECTION_HORIZONTAL = 'horizontal'
BoxLayout.DIRECTION_VERTICAL = 'vertical'

BoxLayout.LeftToRight = 'left2right'
BoxLayout.RightToLeft = 'right2left'
BoxLayout.TopToBottom = 'top2bottom'
BoxLayout.BottomToTop = 'bottom2top'

BoxLayout.horz = function(dir)
    return dir == BoxLayout.LeftToRight or dir == BoxLayout.RightToLeft
end

function BoxLayout:ctor(direction, parent)
    self.super:ctor(parent)
    self.direction = direction or BoxLayout.LeftToRight
    self.items = array()
end

function BoxLayout:Direction()
    return self.direction
end

function BoxLayout:SetDirection(direction)
    if self.direction == direction then
        return
    end
    self.direction = direction
end

function BoxLayout:setupGemo()
    local maxw = 1000
    local maxh = 1000
    if BoxLayout.horz(self.direction) then
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

function BoxLayout:SetGeometry(geometry)
    self.super:SetGeometry(geometry)
end

HBoxLayout = class('HBoxLayout', BoxLayout)

function HBoxLayout:ctor(parent)
    self.super:ctor(parent)
end

VBoxLayout = class('VBoxLayout', BoxLayout)
function VBoxLayout:ctor(parent)
    self.super:ctor(parent)
end
