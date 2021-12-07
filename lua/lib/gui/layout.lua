local class = require('lib.class').class

Layout = class('Layout')

function Layout:ctor(parent)
    self.parent = parent
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
