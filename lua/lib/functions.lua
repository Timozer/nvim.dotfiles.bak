function instanceof(obj, classname)
    if not obj or not obj.__cname then
        return false
    end
    if obj.__cname == classname then
        return true
    end
    return instanceof(obj.super, classname)
end

function class(classname, super)
    local superType = type(super)
    local cls

    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end

    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}

        if superType == "table" then
            -- copy fields from super
            for k,v in pairs(super) do cls[k] = v end
            cls.__create = super.__create
            cls.super    = super
        else
            cls.__create = super
            cls.ctor = function() end
        end

        cls.__cname = classname
        cls.__ctype = 1

        function cls.new(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k,v in pairs(cls) do instance[k] = v end
            instance.class = cls
            instance:ctor(...)
            return instance
        end

    else
        -- inherited from Lua Object
        if super then
            cls = {}
            setmetatable(cls, {__index = super})
            cls.super = super
        else
            cls = {ctor = function() end}
        end

        cls.__cname = classname
        cls.__ctype = 2 -- lua
        cls.__index = cls

        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    end

    return cls
end

function array(...)
    local new_array = {}

    local __data__ = {...}

    local __methods__ = {}
    function __methods__:insert(v, at)
        local len = #__data__ + 1
        at = type(at) == 'number' and at or len
        at = math.min(at, len)
        table.insert(__data__, at, v)
    end
    function __methods__:removeAt(at)
        at = type(at) == 'number' and at or #__data__
        table.remove(__data__, at)
    end
    function __methods__:print()
        print('---> array content begin  <---')
        for i, v in ipairs(__data__) do
            print(string.format('[%s] => ', i), v)
        end
        print('---> array content end  <---')
    end

    -- extend methods here

    local mt = {
        __index = function(t, k)
            if type(k) == 'number' then
                if __data__[k] then
                    return __data__[k]
                end
            else
                if __methods__[k] then
                    return __methods__[k]
                end
            end
        end,
        __newindex = function(t, k, v)
            assert(type(k) == 'number', string.format('error: invalid index [%s]', tostring(k)))
            if k == 0 or k > 
            if nil == __data__[k] then
                print(string.format('warning : [%s] index out of range.', tostring(k)))
                return
            end
            if nil == v then
                print(string.format('warning : can not remove element by using  `nil`.'))
                return
            end
            __data__[k] = v
        end,
        __size = 0,
    }
    setmetatable(new_array, mt)

    return new_array
end

function ToNumber(val)
    if type(val) == 'string' and string.sub(val, -1) == '%' then
        return tonumber(string.sub(val, 1, #val - 1)) / 100
    end
    return tonumber(val)
end

