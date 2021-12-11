require('lib.functions')
require('lib.gui.tools.size')
require('lib.gui.tools.point')

Rect = class('Rect')

function Rect:ctor(...)
    if select('#', ...) == 4 then
        self.x = select(1, ...)
        self.y = select(2, ...)
        self.width = select(3, ...)
        self.height = select(4, ...)
    elseif select('#', ...) == 2 then
        local lh = select(1, ...)
        local rh = select(2, ...)
        assert(instanceof(lh, 'Point'), 'invalid parameters')
        self.x = lh.x
        self.y = lh.y
        if instanceof(rh, 'Point') then
            self.width = rh.x - self.x
            self.height = rh.y - self.y
        elseif instanceof(rh, 'Size') then
            self.width = rh.width
            self.height = rh.height
        else
            assert(false, 'invalid parameters')
        end
    else
        assert(false, string.format('invalid count of parameters [%i]', select('#', ...)))
    end
end

