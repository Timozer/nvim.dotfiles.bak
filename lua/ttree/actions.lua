local utils = require('ttree.utils')

local M = {}

function M.TestAction(node)
    local resp = utils.GetInput("Please input a string: ")
    utils.Input({
        prompt = "Please input a string: ",
        default = "hello neovim",
    }, function(input) 
        if input == nil then
            input = "nothing"
        end
        utils.Notify("[TTree] your input: " .. input)
    end)
end

function M.CR(node)
    if node and node.nodes then
        return M.DirToggle(node)
    end
    return M.EditFile(node)
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

-- function M.GetPreviousWinnr()
--     local cur_winnr = vim.api.nvim_get_current_win()

--     vim.api.nvim_command("wincmd p")
--     local winnr = vim.api.nvim_get_current_win()

--     vim.api.nvim_set_current_win(cur_winnr)

--     return winnr
-- end

function M.EditFile(node)
    -- goto previous window
    vim.api.nvim_command("wincmd p")

    utils.Notify("[TTree] Edit File: " .. node.abs_path .. " winnr: " .. vim.inspect(winnr))
    pcall(vim.cmd, "edit "..vim.fn.fnameescape(node.abs_path))
end

function M.SplitFile(node)
    vim.api.nvim_command("wincmd p")

    utils.Notify("[TTree] Edit File: " .. node.abs_path .. " winnr: " .. vim.inspect(winnr))
    pcall(vim.cmd, "sp "..vim.fn.fnameescape(node.abs_path))
end

function M.VSplitFile(node)
    vim.api.nvim_command("wincmd p")
    utils.Notify("[TTree] Edit File: " .. node.abs_path .. " winnr: " .. vim.inspect(winnr))
    pcall(vim.cmd, "vsp "..vim.fn.fnameescape(node.abs_path))
end

function M.DirToggle(node)
    if not node or not node.nodes then
        return
    end

    if node.status == "opened" then
        node:Collapse()
    else
        node:Expand()
    end

    return true
end

function M.DirExpand(node)
end

function M.DirCollapse(node)
end

function M.DirIn(node)
end

function M.DirOut(node)
end

function M.setup(opts)
end

return M
