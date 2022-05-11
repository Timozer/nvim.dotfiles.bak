local M = {}

function M.Encoding()
    return vim.opt.fileencoding:get()
end

function M.Fileformat()
    return vim.bo.fileformat
end

function M.Filetype()
    return vim.bo.filetype
end

function M.Filename(typ)
    if typ == "relative" then
        return vim.fn.expand('%:p:.')
    elseif typ == "absolute" then
        return vim.fn.expand('%:p')
    else
        return vim.fn.expand('%:t')
    end
end

return M
