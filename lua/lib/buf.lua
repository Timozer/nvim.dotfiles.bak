local M = {
    old_keymaps = {}
}
M.__index = M

function M.New(opts)

    local buf = setmetatable(opts or {}, M)
    buf.bufnr = vim.api.nvim_create_buf(false, false)
    buf.options = {}

    if buf.name then
        vim.api.nvim_buf_set_name(buf.bufnr, buf.name)
    end

    if buf.opts then
        buf:SetOptions(buf.opts)
    end

    if buf.keymaps then
        buf:SetKeymaps(buf.keymaps)
    end

    return buf
end

function M:SetOption(key, val)
    if vim.fn.exists('+'..key) == 0 or val == nil then
        return
    end
    self.options[key] = val
    if self:Valid() then
        vim.api.nvim_buf_set_option(self.bufnr, key, val)
    end
end

function M:SetOptions(opts)
    for k, v in pairs(opts) do
        self:SetOption(k, v)
    end
end

local maps = {
    {
        mode = "", -- n, i, v, x, !
        lhs = "",
        rhs = "",
        opts = {}, -- nowait, silent, script, expr, unique, callback, desc
    }
}
-- keymap example:
-- {
--     mode = 'n',
--     lhs = '<CR>',
--     rhs = '',
--     opts = { 
--         callback = require('ftree.actions').CR,
--         desc = 'CR Action' 
--     }
-- }
--
function M:SetKeymaps(maps)
    if not self:Valid() then
        return
    end
    maps = maps or {}

    for _, val in ipairs(self.old_keymaps) do
        vim.api.nvim_buf_del_keymap(self.bufnr, val.mode, val.lhs)
    end

    for _, val in ipairs(maps) do
        vim.api.nvim_buf_set_keymap(self.bufnr, val.mode, val.lhs, val.rhs, val.opts)
    end

    self.old_keymaps = maps
end

function M.GetByFileName(fname)
    local buf = setmetatable({}, M)
    buf.name = fname

    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_get_name(bufnr) == buf.name then
            buf.bufnr = bufnr
            return buf
        end
    end

    return nil
end

function M.DelBufByNrs(nrs, force)
    force = force or true
    nrs = nrs or {}
    if type(nrs) ~= "table" then
        nrs = { nrs }
    end

    for _, nr in ipairs(nrs) do
        if vim.api.nvim_buf_is_valid(nr) then
            vim.api.nvim_buf_delete(nr, { force = force })
        end
    end
end

function M.DelBufByNames(names, force)
    names = names or {}
    if type(names) ~= "table" then
        names = { names }
    end

    nrs = {}
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        bname = vim.api.nvim_buf_get_name(bufnr)
        for _, name in ipairs(names) do
            if bname == name then
                table.insert(nrs, bufnr)
                break
            end
        end
    end

    M.DelBufByNrs(nrs, force)
end

function M.DelBufByNamePrefix(prefix, force)
    nrs = {}
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        bname = vim.api.nvim_buf_get_name(bufnr)
        if string.find(bname, prefix) == 1 then
            table.insert(nrs, bufnr)
        end
    end
    M.DelBufByNrs(nrs, force)
end

function M.RenameBuf(oldname, newname)
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_get_name(bufnr) == oldname then
            vim.api.nvim_buf_set_name(bufnr, newname)
            break
        end
    end
end

function M.RenameBufByNamePrefix(prefix, newprefix)
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        bname = vim.api.nvim_buf_get_name(bufnr)
        s, e = string.find(bname, prefix)
        if s == 1 then
            newname = newprefix .. string.sub(bname, e + 1)
            vim.api.nvim_buf_set_name(bufnr, newname)
        end
    end
end


function M:Loaded()
    return self:Valid() and vim.api.nvim_buf_is_loaded(self.bufnr)
end

function M:Valid()
    return self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr)
end

return M
