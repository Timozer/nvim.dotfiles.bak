
local function FuncComponent()
    return "TestComponent"
end

local M = {
    data = {
        {"%f%m%r", "2"},
        {"3"},
        FuncComponent,
        "StrComponent",
        {vim.bo.filetype, "%b", "%p%% : %l/%L,%c%V"},
    },
    disabled_filetypes = {
        "FTree"
    }
}

function StrTrim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function M.StatusLine()
    local ftype = vim.bo.filetype

    for _, ft in pairs(M.disabled_filetypes) do
        if ft == ftype then
            return ''
        end
    end

    local status = ""

    for i, sect in ipairs(M.data) do
        local sep = "%=%"
        if i == 1 then
            sep = "%-"
        end

        if type(sect) == "string" then
            status = status .. sep .. "(" .. sect .. "%)"
        elseif type(sect) == "function" then
            status = status .. sep .. "(" .. sect() .. "%)"
        elseif type(sect) == "table" then
            local items = {}
            for _, item in pairs(sect) do
                if type(item) == "string" and StrTrim(item) ~= "" then
                    table.insert(items, StrTrim(item))
                elseif type(item) == "function" and StrTrim(item()) ~= "" then
                    table.insert(items, StrTrim(item()))
                end
            end
            status = status .. sep .. "(" .. table.concat(items, " | ") .. "%)"
        end
    end

    return status
end

function M.SetUp(opts)
    opts = opts or {}

    vim.cmd([[
        augroup SLINE
        autocmd!
        autocmd VimResized * redrawstatus
        augroup END
    ]])

    vim.go.statusline = "%{%v:lua.require('sline').StatusLine()%}"
end
-- %#lualine_a_normal# [No Name] %#lualine_transitional_lualine_a_normal_to_lualine_b_normal#%#lualine_b_normal#  master %#lualine_transitional_lualine_b_normal_to_lualine_c_normal#%<%#lualine_c_normal#%=%#lualine_transitional_lualine_b_normal_to_lualine_c_normal#%#lualine_b_normal# utf-8 |%#lualine_b_normal#  %#lualine_transitional_lualine_a_normal_to_lualine_b_normal#%#lualine_a_normal# %3p%% |%#lualine_a_normal# %3l:%-2v 

-- %<%#lualine_c_inactive# [No Name] %#lualine_c_inactive#%=%#lualine_c_inactive# %3l:%-2v 
return M
