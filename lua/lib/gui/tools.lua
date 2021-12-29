require('PLoop')

PLoop(function(_ENV)
    namespace "gui"

    class "StringNumber" (function(_ENV)
        field {
            __value = ''
        }

        property "Value" { 
            type = String,
            get = function(self) return tonumber(self.__value) end,
            set = function(self, value) 
                if tonumber(value) == nil then 
                    throw('invalid number string')
                end
                self.__value = value
            end,
            throwable = true,
        }

        function StringNumber(self, value)
            self.Value = value
        end

        function IsFloat(self)
            return string.find(self.__value, '%.') ~= nil
        end

        function IsInteger(self)
            return string.find(self.__value, '%.') == nil
        end
    end)

    class "Point" (function(_ENV)
        property "x" { type = Number + String, }
        property "y" { type = Number + String, }

        __Arguments__{ Number + String, Number + String }
        function Point(self, x, y)
            self.x = x
            self.y = y
        end

        __Arguments__{ Point }
        function Point(self, pt)
            self.x = pt.x
            self.y = pt.y
        end
    end)

    class "Size" (function(_ENV)
        property "width" { type = Number + String }
        property "height" { type = Number + String }

        __Arguments__{ Number + String, Number + String }
        function Size(self, w, h)
            self.width = w
            self.height = h
        end

        __Arguments__{ Size }
        function Size(self, s)
            self.width = s.width
            self.height = s.height
        end
    end)

    class "Rect" (function(_ENV)
        property "x" { type = Number + String, }
        property "y" { type = Number + String, }
        property "width" { type = Number + String, }
        property "height" { type = Number + String, }

        __Arguments__{ Number + String, Number + String, Number + String, Number + String }
        function Rect(self, x, y, width, height)
            self.x = x
            self.y = y
            self.width = width
            self.height = height
        end

        __Arguments__{ Point, Size }
        function Rect(self, point, size)
            self.x = point.x
            self.y = point.y
            self.width = size.width
            self.height = size.height
        end

        __Arguments__{ Rect }
        function Rect(self, rect)
            self.x = rect.x
            self.y = rect.y
            self.width = rect.width
            self.height = rect.height
        end
    end)
end)
