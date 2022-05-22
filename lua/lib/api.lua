local M = {}

local CTRL_V = vim.api.nvim_replace_termcodes('<C-v>', true, true, true)
local CTRL_S = vim.api.nvim_replace_termcodes('<C-s>', true, true, true)

function M.GetMode()
    local mode = vim.api.nvim_get_mode().mode:sub(1, 1)
    if mode == 'i' then
        return 'i' -- insert
    elseif mode == 'v' or mode == 'V' or mode == CTRL_V then
        return 'x' -- visual
    elseif mode == 's' or mode == 'S' or mode == CTRL_S then
        return 's' -- select
    elseif mode == 'c' and vim.fn.getcmdtype() ~= '=' then
        return 'c' -- cmdline
    end
end

function M.IsInsertMode()
    return M.GetMode() == "i"
end

function M.IsCmdMode()
    return M.GetMode() == "c"
end

function M.IsSelectMode()
    return M.GetMode() == "s"
end

function M.IsVisualMode()
    return M.GetMode() == "x"
end

-- function M.GetScreenCursor()
--     if M.IsCmdMode() then
--         local cursor = api.get_cursor()
--         return { cursor[1], cursor[2] + 1 }
--     end
--     local cursor = api.get_cursor()
--     local pos = vim.fn.screenpos(0, cursor[1], cursor[2] + 1)
--     return { pos.row, pos.col - 1 }
-- end

return M
