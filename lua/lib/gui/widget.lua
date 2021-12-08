require('lib.functions')

Border = class('Border')

Border.STYLE_NONE = 'none'
Border.STYLE_SHADOW = 'shadow'
Border.STYLE_DOUBLE = {"╔", "═", "╗", "║", "╝", "═", "╚", "║"}
Border.STYLE_ROUNDED = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
Border.STYLE_SINGLE = { "┌", "─", "┐", "│", "┘", "─", "└", "│" }
Border.STYLE_SOLID = { "▛", "▀", "▜", "▐", "▟", "▄", "▙", "▌" }

function Border:ctor(widget, style)
    self.widget = widget
    self.style = style

    self.winopts = {
        style    = "minimal",
        relative = widget.relative,
        width    = self.widget.size.width + 2,
        height   = self.widget.size.height + 2,
        row      = self.widget.pos.row - 1,
        col      = self.widget.pos.col - 1,
    }
end

function Border:Show()
    if self.style == Border.STYLE_NONE or self.style == Border.STYLE_SHADOW then
        return
    end

    self.bufnr = vim.api.nvim_create_buf(false, true)

    local context = { 
        self.style[1] .. string.rep(self.style[2], self.widget.size.width) .. self.style[3] 
    }
    local middle_line = self.style[8] .. string.rep(' ', self.widget.size.width) .. self.style[4]
    for i=1, self.widget.size.height do
        table.insert(context, middle_line)
    end
    table.insert(
        context, 
        self.style[7] .. string.rep(self.style[6], self.widget.size.width) .. self.style[5]
        )

    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, context)
    vim.api.nvim_buf_set_option(self.bufnr, 'modifiable', false)

    self.winid = vim.api.nvim_open_win(self.bufnr, true, self.winopts)
end

Widget = class('Widget')

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

local opts = {
    relative = Widget.RELATIVE_WIN,
    size = '80%',
    pos = '50%',
    bufopts = {
        buflisted = false,
        modifiable = false,
        readonly = true,
    },
    winopts = {
    },
    style = 'minimal',
    enter = true,
    border = Border.STYLE_ROUNDED,
}

function Widget:ctor(opts, parent)
    self.bufnr  = -1
    self.winid  = -1
    self.hidden = true

    self.relative = opts.relative or Widget.RELATIVE_WIN

    local container_info = GetContainerInfo({ relative = self.relative })

    -- size format:
    --     1. size = '80%'
    --     2. size = { width = '80%', height = '80%' }
    --     3. size = 80
    --     4. size = { width = 80, height = 80 }
    self.size = opts.size or '80%'
    -- pos format, pos is the window's center:
    --     1. pos = '50%'
    --     2. pos = { row = '80%', col = '80%' }
    --     3. pos = 50
    --     4. pos = { row = 50, col = 50 }
    self.pos = opts.pos or '50%'

    self.bufopts = opts.bufopts or {
        buflisted = false,
        modifiable = false,
        readonly = true,
    }

    -- win options, don't set {border, width, height, row, col}, it will be override by
    -- size
    self.winopts = opts.winopts or {}

    self.size = CalcWinSize(self.size, container_info.size)
    self.pos = CalcWinPos(self.pos, self.size, container_info.size)

    self.enter = opts.enter or true

    self.style = opts.style or 'minimal'
    self.border = opts.border or Border.STYLE_NONE
end

function Widget:Width()
    return self.size.width
end

function Widget:Height()
    return self.size.height
end

function Widget:IsHidden()
    return self.hidden
end

function Widget:Show()
    if not self.hidden then
        return
    end

    if self.border then
        local border = Border.new(self, Border.STYLE_ROUNDED)
        border:Show()
    end

    if self.bufnr < 1 then
        self.bufnr = vim.api.nvim_create_buf(false, true)
        assert(self.bufnr, 'failed to create buffer')

        for key, val in pairs(self.bufopts) do
            vim.api.nvim_buf_set_option(self.bufnr, key, val)
        end
    end

    if self.winid < 1 then
        self.winid = vim.api.nvim_open_win(
                self.bufnr,
                self.enter,
                {
                    relative = self.relative,
                    border   = 'none',
                    width    = self.size.width,
                    height   = self.size.height,
                    row      = self.pos.row,
                    col      = self.pos.col,
                    style    = self.style,
                }
            )
        for key, val in pairs(self.winopts) do
            vim.api.nvim_win_set_option(self.winid, key, val)
        end
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
