require('lib.functions')

Number = class('Number')

function Number:ctor(number)
    assert(
        type(number) == 'string' and tonumber(number) ~= nil,
        string.format('invalid number [%s]', tostring(number)
    )

    self._val = number
    self.value = tonumber(self._val)
end

function Number:IsFloat()
    return string.find(self._val, '.') ~= nil
end

function Number:IsInteger()
    return string.find(self._val, '.') == nil
end
