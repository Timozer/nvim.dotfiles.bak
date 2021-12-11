require('lib.functions')

Size = class('Size')

function Size:ctor(width, height)
    self.width = width
    self.height = height
end

Size.INVALID_SIZE = Size.new(-1, -1)
