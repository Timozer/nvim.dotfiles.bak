local M = {}
M.__index = M

function M.New(ns_name)
    local ret = setmetatable({}, M)
    ret._namespace_name = ns_name
    ret._namespace_id = vim.api.nvim_create_namespace(ret._namespace_name)
    return ret
end

local highlights = {
    {
        name = 'HlTest01',
        link = nil,
        inherit = nil,
    },
}

local opt_keys = { 
    'default',
    'fg', 'bg', 
    'ctermfg', 'ctermbg', 
    'bold', 'italic', 'reverse', 'standout', 
    'underline', 'underlineline', 'undercurl', 'underdot', 'underdash', 
    'strikethrough', 
}

function M:SetHighlights(highlights)
    for i, hl in highlights do
        opts = {}
        if hl.link ~= nil then
            opts.link    = hl.link
            opts.default = hl.default
        else
            for _, key in ipairs(opt_keys) do
                opts[key] = hl[key] ~= nil and hl[key] or (
                    hl.inherit ~= nil and vim.fn.synIDattr(vim.fn.hlID(hl.inherit), key) or nil
                    )
            end
        end
        vim.api.nvim_set_hl(self._namespace_id, hl.name, opts)
    end
end

return M
