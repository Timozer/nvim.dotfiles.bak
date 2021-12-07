-- local cls = require('lib.class')

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

local Widget = class('Widget')

Widget.RELATIVE_EDITOR = 'editor'
Widget.RELATIVE_WIN    = 'win'
Widget.RELATIVE_CURSOR = 'cursor'

function GetEditorSize()
    return { width = vim.o.columns, height = vim.o.lines }
end

function GetWindowSize(winid)
  winid = winid or 0
  return {
    width = vim.api.nvim_win_get_width(winid),
    height = vim.api.nvim_win_get_height(winid),
  }
end

function GetContainerInfo(pos)
    if pos.relative == Widget.RELATIVE_EDITOR then
        return {size = GetEditorSize()}
    end

    if pos.relative == Widget.RELATIVE_CURSOR or pos.relative == Widget.RELATIVE_WIN then
        return { size = GetWindowSize(pos.win) }
    end
end

function ToNumber(val)
    if type(val) == 'string' and string.sub(val, -1) == '%' then
        return tonumber(string.sub(val, 1, #val - 1)) / 100
    end
    return tonumber(val)
end

function CalcWinSize(size, container_size)
    if type(size) ~= "table" then
        size = { width = size, height = size, }
    end

    local width = ToNumber(size.width)
    assert(width, 'invalid size.width')
    if math.floor(width) < width then
        width = math.floor(width * container_size.width)
    end

    local height = ToNumber(size.height)
    assert(height, 'invalid size.height')
    if math.floor(height) < height then
        height = math.floor(height * container_size.height)
    end

    return { width = width, height = height, }
end

function CalcWinPos(pos, win_size, container_size)
    if type(pos) ~= 'table' then
        pos = { row = pos, col = pos, }
    end

    local row = ToNumber(pos.row)
    assert(row, 'invalid pos.row')
    if math.floor(row) < row then
        row = math.floor(row * (container_size.height - win_size.height))
    end

    local col = ToNumber(pos.col)
    assert(col, 'invalid pos.col')
    if math.floor(col) < col then
        col = math.floor(col * (container_size.width - win_size.width))
    end

    return { row = row, col = col, }
end

function Widget:ctor(opts, parent)
    self.bufnr  = -1
    self.winid  = -1
    self.hidden = true

    -- size format:
    --     1. size = '80%'
    --     2. size = { width = '80%', height = '80%' }
    --     3. size = 80
    --     4. size = { width = 80, height = 80 }
    self.size = opts.size or '80%'
    -- position format, pos is the window's center:
    --     1. position = '50%'
    --     2. position = { row = '80%', col = '80%' }
    --     3. position = 50
    --     4. position = { row = 50, col = 50 }
    self.position = opts.position or '50%'

    self.bufopts = opts.bufopts or { 
        buflisted = false, 
        modifiable = false,
        readonly = true,
    }

    -- win options, don't set {width, height, row, col}, it will be override by
    -- size
    self.winopts = opts.winopts or {
        relative = 'editor',
        style    = 'minimal',
        border   = 'rounded',
    }

    local info = GetContainerInfo({ relative = self.winopts.relative })
    self.size = CalcWinSize(self.size, info.size)
    self.position = CalcWinPos(self.position, self.size, info.size)

    self.winopts.width  = self.size.width
    self.winopts.height = self.size.height
    self.winopts.row    = self.position.row
    self.winopts.col    = self.position.col

    self.enter = opts.enter or true
end

function Widget:Width()
    return self.width
end

function Widget:Height()
    return self.height
end

function Widget:IsHidden()
    return self.hidden
end

function Widget:Show()
    if not self.hidden then
        return
    end

    if self.bufnr < 1 then
        self.bufnr = vim.api.nvim_create_buf(false, true)
        assert(self.bufnr, 'failed to create buffer')

        for key, val in pairs(self.bufopts) do
            vim.api.nvim_buf_set_option(self.bufnr, key, val)
        end
    end

    if self.winid < 1 then
        self.winid = vim.api.nvim_open_win(self.bufnr, self.enter, self.winopts)
    end

    self.hidden = false
end

function Widget:Layout()
    return self.layout
end

function Widget:SetLayout(layout)
    self.layout = layout
end

function Widget:AddWidget(child)
    if not self.child_widgets then
        self.child_widgets = {}
    end
    table.insert(self.child_widgets, child)
end

function Widget:SetParent(parent)
    self.parent = parent
end

return Widget
