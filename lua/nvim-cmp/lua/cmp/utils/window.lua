local cache = require('cmp.utils.cache')
local misc = require('cmp.utils.misc')
local buffer = require('cmp.utils.buffer')
local api = require('cmp.utils.api')

---@class cmp.Window
---@field public name string
---@field public win number|nil
---@field public thumb_win number|nil
---@field public sbar_win number|nil
---@field public style cmp.WindowStyle
---@field public opt table<string, any>
---@field public buffer_opt table<string, any>
---@field public cache cmp.Cache
local window = {}

---new
---@return cmp.Window
window.new = function()
  local self = setmetatable({}, { __index = window })
  self.name = misc.id('cmp.utils.window.new')
  self.win = nil
  self.sbar_win = nil
  self.thumb_win = nil
  self.style = {}
  self.cache = cache.new()
  self.opt = {}
  self.buffer_opt = {}
  return self
end

---Update
window.update = function(self)
    local info = self:info()
    if info.scrollable then
        -- Draw the background of the scrollbar

        if not info.border_info.visible then
            local style = {
                relative = 'editor',
                style = 'minimal',
                width = 1,
                height = self.style.height,
                row = info.row,
                col = info.col + info.width - info.scrollbar_offset, -- info.col was already contained the scrollbar offset.
                zindex = (self.style.zindex and (self.style.zindex + 1) or 1),
            }
            if self.sbar_win and vim.api.nvim_win_is_valid(self.sbar_win) then
                vim.api.nvim_win_set_config(self.sbar_win, style)
            else
                style.noautocmd = true
                self.sbar_win = vim.api.nvim_open_win(buffer.ensure(self.name .. 'sbar_buf'), false, style)
                vim.api.nvim_win_set_option(self.sbar_win, 'winhighlight', 'EndOfBuffer:PmenuSbar,NormalFloat:PmenuSbar')
            end
        end

        -- Draw the scrollbar thumb
        local thumb_height = math.floor(info.inner_height * (info.inner_height / self:get_content_height()) + 0.5)
        local thumb_offset = math.floor(info.inner_height * (vim.fn.getwininfo(self.win)[1].topline / self:get_content_height()))

        local style = {
            relative = 'editor',
            style = 'minimal',
            width = 1,
            height = math.max(1, thumb_height),
            row = info.row + thumb_offset + (info.border_info.visible and info.border_info.top or 0),
            col = info.col + info.width - 1, -- info.col was already added scrollbar offset.
            zindex = (self.style.zindex and (self.style.zindex + 2) or 2),
        }
        if self.thumb_win and vim.api.nvim_win_is_valid(self.thumb_win) then
            vim.api.nvim_win_set_config(self.thumb_win, style)
        else
            style.noautocmd = true
            self.thumb_win = vim.api.nvim_open_win(buffer.ensure(self.name .. 'thumb_buf'), false, style)
            vim.api.nvim_win_set_option(self.thumb_win, 'winhighlight', 'EndOfBuffer:PmenuThumb,NormalFloat:PmenuThumb')
        end
    else
        if self.sbar_win and vim.api.nvim_win_is_valid(self.sbar_win) then
            vim.api.nvim_win_hide(self.sbar_win)
            self.sbar_win = nil
        end
        if self.thumb_win and vim.api.nvim_win_is_valid(self.thumb_win) then
            vim.api.nvim_win_hide(self.thumb_win)
            self.thumb_win = nil
        end
    end

    -- In cmdline, vim does not redraw automatically.
    if api.is_cmdline_mode() then
        vim.api.nvim_win_call(self.win, function()
            misc.redraw()
        end)
    end
end

---Get scroll height.
---NOTE: The result of vim.fn.strdisplaywidth depends on the buffer it was called in (see comment in cmp.Entry.get_view).
---@return number
window.get_content_height = function(self)
    if not self:option('wrap') then
        return vim.api.nvim_buf_line_count(self:get_buffer())
    end
    local height = 0
    vim.api.nvim_buf_call(self:get_buffer(), function()
        for _, text in ipairs(vim.api.nvim_buf_get_lines(self:get_buffer(), 0, -1, false)) do
            height = height + math.max(1, math.ceil(vim.fn.strdisplaywidth(text) / self.style.width))
        end
    end)
    return height
end

return window
