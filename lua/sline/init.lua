local M = {
    config = {
        disabled_filetypes = {
            "FTree"
        }
    }
}

function M.Redraw()
end

function M.StatusLine()
    local retval
    local ftype = vim.bo.filetype

    for _, ft in pairs(M.config.disabled_filetypes) do
        if ft == ftype then
            return ''
        end
    end
end

function M.SetUp(opts)
    opts = opts or {}

    vim.cmd('autocmd SLINE VimResized * redrawstatus')
    vim.go.statusline = "%{%v:lua.require('sline').StatusLine()%}"
end

return M
