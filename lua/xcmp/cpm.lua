
-- cpm is short for Completion Popup Menu

local win = require('lib.win')

local M = {}
M.__index = M

function M.New()
    local ret = setmetatable({}, M)
    ret.menu = win.New({
        enter = true,
        config = {
            relative = 'cursor',
            style = 'minimal',
            row = 1,
            col = 1,
            width = 8,
            height = 8,
        },
        options = {
            conceallevel = 2,
            concealcursor = 'n',
            cursorlineopt = 'line',
            foldenable = false,
            wrap = false,
            scrolloff = 0,
            sidescrolloff = 0,
            winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None',
            winblend = vim.o.pumblend,
        }
    })
    return ret
end

function M:Open(ctx, sources)
    self.menu:Open()
end

local cpm = M.New()
cpm:Open()

return M
