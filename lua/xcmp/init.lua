local au = require('lib.au')
local cursor = require('lib.cursor')
local vapi = require('lib.api')

local M = {
    autocmds = au.NewGroup('XCMP'),
}

local function GetCursor()
    local win = vapi.IsCmdMode() and 1 or 0
    return cursor.New(win)
end

local function OnTextChanged()
    local cursor = GetCursor()
    line = cursor:GetLineBefore()
    s, e = string.find(line, '[^%s]+$')
    prefix = string.sub(line, s, e)
end

function M.SetUp(opts)
    opts = opts or {}
    M.autocmds:AddCmd({'TextChangedI', 'TextChangedP'}, {
        desc = 'for completion',
        callback = OnTextChanged,
    })
end

return M
