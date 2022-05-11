local M = {
    data = {
        {
            "%#SlineFilename#%{%v:lua.require('sline.components').Filename('relative')%}%#SlineFileStatus#%m%r"
        },
        {
            "%#SlineFiletype#",
            require("sline.components").Filetype, 
            "%#SlineFileformat#",
            require("sline.components").Fileformat, 
            "%#SlineEncoding#",
            require("sline.components").Encoding, 
            "%#SlineLocation#",
            "%3p%% : %l/%L,%c"
        },
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
            local highlight_str = "%#SlineDefault#"
            for _, item in pairs(sect) do
                local context = item
                if type(item) == "function" then
                    context = item()
                end
                context = StrTrim(context)
                if context:match("^%%#.*#$") then
                    highlight_str = context
                else
                    if context ~= "" then
                        table.insert(items, highlight_str .. context)
                    end
                    highlight_str = "%#SlineDefault#"
                end
            end
            status = status .. "%<" .. sep .. "(" .. table.concat(items, " | ") .. "%)"
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

return M
