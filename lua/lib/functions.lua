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

    local __data__ = {}
    local __size__ = 0

    local __methods__ = {}

    function __methods__:append(v)
        table.insert(__data__, v)
        __size__ = __size__ + 1
    end

    function __methods__:size()
        return __size__
    end

    function __methods__:insert(i, v)
        assert(
            type(i) == 'number' and i ~= 0 and math.abs(i) <= __size__,
            'invalid index'
        )
        table.insert(__data__, i, v)
        __size__ = __size__ + 1
    end

    function __methods__:erase(i)
        assert(
            type(i) == 'number' and i ~= 0 and math.abs(i) <= __size__,
            'invalid index'
        )
        table.remove(__data__, i)
        __size__ = __size__ - 1
    end

    function __methods__:clear()
        __data__ = {}
        __size__ = 0
    end

    -- extend methods here
    local mt = {
    }

    mt.__index = function(t, k)
        if type(k) == 'number' then
            assert(
                k ~= 0 and math.abs(k) <= __size__,
                string.format('[%s] index out of range', tostring(k))
            )
            return __data__[k]
        end

        assert(__methods__[k], string.format('unknow key [%s]', tostring(k)))
        return __methods__[k]
    end

    mt.__newindex = function(t, k, v)
        assert(type(k) == 'number', string.format('error: invalid index [%s]', tostring(k)))
        assert(
            k ~= 0 and math.abs(k) <= __size__,
            string.format('[%s] index out of range', tostring(k))
        )
        __data__[k] = v
    end

    mt.__tostring = function(t)
        local ret = '['
        i = 1
        while i <= __size__ do
            ret = string.format('%s%s, ', ret, tostring(__data__[i]))
            i = i + 1
        end
        ret = string.format('%s\b\b]', ret)
        return ret
    end

    for _, v in ipairs{...} do
        __methods__:append(v)
    end


    setmetatable(new_array, mt)
    return new_array
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function length(tbl)
    local ret = 0
    for n in pairs(tbl) do 
        ret = ret + 1 
    end
    return ret
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end
