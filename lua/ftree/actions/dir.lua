local lib = require "ftree.lib"
local utils = require "ftree.utils"
local core = require "ftree.core"
local log = require "ftree.log"

local M = {
    current_tab = vim.api.nvim_get_current_tabpage(),
}

function M.change_dir(dir, with_open)
    if not core.get_explorer() then
        return
    end
    local no_change = vim.fn.expand(dir) == core.get_cwd()
    local new_tab = vim.api.nvim_get_current_tabpage()
    local is_window = (vim.v.event.scope == "window" or vim.v.event.changed_window) and new_tab == M.current_tab
    if no_change or is_window then
        return
    end
    M.current_tab = new_tab
    M.force_dirchange(dir, with_open)
end

function M.force_dirchange(dir, with_open)
    local ps = log.profile_start("change dir %s", dir)

    if vim.tbl_isempty(vim.v.event) then
        vim.cmd("cd " .. vim.fn.fnameescape(dir))
    end
    core.init(dir)
    if with_open then
        require("ftree.lib").open()
    else
        require("ftree.renderer").draw()
    end

    log.profile_end(ps, "change dir %s", dir)
end

function M.dir_in(node)
    if node.nodes ~= nil then
        M.change_dir(lib.get_last_group_node(node).absolute_path)
    end
end

function M.dir_out(node)
    if not node then
        return
    else
        local cwd = utils.path_remove_trailing(core.get_cwd())
        M.change_dir(vim.fn.fnamemodify(cwd, ":h"))
        return require("ftree.actions.find-file").fn(node.absolute_path)
    end
end

return M
