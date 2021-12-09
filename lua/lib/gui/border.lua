require('lib.functions')
require('lib.gui.common')
require('lib.gui.gobject')

Border = class('Border', GObject)

Border.STYLE_NONE    = 'none'
Border.STYLE_SHADOW  = 'shadow'
Border.STYLE_DOUBLE  = {"╔", "═", "╗", "║", "╝", "═", "╚", "║"}
Border.STYLE_ROUNDED = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
Border.STYLE_SINGLE  = { "┌", "─", "┐", "│", "┘", "─", "└", "│" }
Border.STYLE_SOLID   = { "▛", "▀", "▜", "▐", "▟", "▄", "▙", "▌" }

function Border:ctor(widget, opts)
    self.super:ctor(opts)

    self.widget = widget
    self.style = opts.style or Border.STYLE_NONE

    self.relative = self.widget.relative
    self.size = {
        width  = self.widget.size.width + 2,
        height = self.widget.size.height + 2,
    }
    self.pos = {
        row = self.widget.pos.row - 1,
        col = self.widget.pos.col - 1,
    }

    self.bufopts.buflisted = false
    self.bufopts.modifiable = true
    self.winopts.winblend = self.winopts.winblend or 100
end

function Border:Show()
    if self.style == Border.STYLE_NONE or self.style == Border.STYLE_SHADOW then
        return
    end

    self:Create()

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
end
