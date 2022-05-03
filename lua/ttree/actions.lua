local M = {
    keymaps = {}
}

function M.CR(node)
    vim.schedule(function()
        vim.notify("[TTree] CR keymap call")
    end)
end

function M.OpenFileFunc(mode)
    return function(node)
        local tabpage = api.nvim_get_current_tabpage()
        local win_ids = api.nvim_tabpage_list_wins(tabpage)

        for _, winnr in ipairs(win_ids) do
            if node.abs_path == vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(winnr)) then
                vim.api.nvim_set_current_win(winnr)
                return
            end
        end
    end
end

function M.EditFile(node)
    pcall(vim.cmd, "edit "..vim.fn.fnameescape(node.abs_path))
end


function M.setup(opts)
    M.keymaps = opts or {}
end

return M
