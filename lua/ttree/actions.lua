local utils = require('ttree.utils')
local job = require('ttree.job')
local log = require('ttree.log')

local M = {
    finfo_win = nil,
    marks = {},
}

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
    pcall(vim.cmd, "edit "..vim.fn.fnameescape(node.ftype == "link" and node.link_to or node.abs_path))
end

function M.SplitFile(node)
    vim.api.nvim_command("wincmd p")

    utils.Notify("[TTree] Edit File: " .. node.abs_path .. " winnr: " .. vim.inspect(winnr))
    pcall(vim.cmd, "sp "..vim.fn.fnameescape(node.ftype == "link" and node.link_to or node.abs_path))
end

function M.VSplitFile(node)
    vim.api.nvim_command("wincmd p")
    utils.Notify("[TTree] Edit File: " .. node.abs_path .. " winnr: " .. vim.inspect(winnr))
    pcall(vim.cmd, "vsp "..vim.fn.fnameescape(node.ftype == "link" and node.link_to or node.abs_path))
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

function M.DirIn(node, renderer)
    if node.nodes ~= nil then
        node:Expand()
        renderer.tree = node
        vim.api.nvim_command("cd " .. node.abs_path)
        return true
    end
    return false
end

function M.DirOut(node, renderer)
    local cur_tree = renderer.tree

    if cur_tree.parent == nil then
        local tree = require("ttree.node").New({
                abs_path = vim.fn.fnamemodify(cur_tree.abs_path, ":h"),
                ftype = "folder",
                status = "opened",
                nodes = { cur_tree }
            })
        cur_tree.parent = tree
    end

    renderer.tree = cur_tree.parent
    vim.api.nvim_command("cd " .. renderer.tree.abs_path)
    return true
end

function M.NewFile(node, renderer)
    local tmpNode = node
    if node.ftype == "file" or (node.ftype == "link" and node.link_type == "file") then
        tmpNode = node.parent
    elseif node.ftype == "folder" or (node.ftype == "link" and node.link_type == "folder") then
        if node.status == "closed" then
            tmpNode = node.parent
        end
    end

    local opts = { prompt = "["..tmpNode.abs_path.."]" .. " New dir or file: " }

    vim.ui.input(opts, function(fname)
        if not fname or #fname == 0 then
            return
        end

        vim.api.nvim_command("normal! :")

        local abs_path = utils.path_join({ tmpNode.abs_path, fname })

        if utils.file_exists(abs_path) then
            utils.Notify(fname .. " already exists")
            return
        end

        local dir = vim.fn.fnamemodify(fname, ":h")
        local job_mkdir = job.New({
            path = "mkdir",
            args = { "-p", dir },
            cwd = tmpNode.abs_path, 
        })
        job_mkdir:Run()
        if job_mkdir.status ~= 0 then
            utils.Notify("fail to create " .. fname .. ", err: " .. job_mkdir.stderr)
            return
        end

        local filename = vim.fn.fnamemodify(fname, ":t")
        if #filename > 0 then
            local job_touch = job.New({
                path = "touch",
                args = { fname },
                cwd = tmpNode.abs_path, 
            })
            job_touch:Run()
            if job_touch.status ~= 0 then
                utils.Notify("fail to create " .. fname .. ", err: " .. job_touch.stderr)
                return
            end
        end

        tmpNode:Expand()
    end)
    return true
end

function M.RenameFile(node)
    local dir = vim.fn.fnamemodify(node.abs_path, ":h")
    local opts = { 
        prompt = "["..dir.."]" .. " Rename " .. node.name .. " to: ",
        default = node.name,
    }

    vim.ui.input(opts, function(fname)
        if not fname or #fname == 0 or fname == node.name then
            return
        end

        local abs_path = utils.path_join({dir, fname})
        if utils.file_exists(abs_path) then
            utils.Notify(fname .. " already exists")
            return
        end

        local job_mv = job.New({
            path = "mv",
            args = { node.name, fname },
            cwd = dir, 
        })
        job_mv:Run()
        if job_mv.status ~= 0 then
            utils.Notify("fail to rename " .. fname .. ", err: " .. job_mv.stderr)
            return
        end

        node.name = fname
        node.abs_path = abs_path
        if node.ftype == "folder" or (node.ftype == "link" and node.link_type == "folder") then
            node.nodes = {}
            if node.status == "opened" then
                node:Expand()
            end
        elseif node.ftype == "file" or (node.ftype == "link" and node.link_type == "file") then
            -- TODO rename loaded buffers
        end
    end)
    return true
end

function M.RemoveFile(node, renderer)
    if node == renderer.tree then
        utils.Notify("cannot remove root folder")
        return
    end

    local parent = node.parent

    local opts = { prompt = "Delete " .. node.abs_path .. " ?[y/n] " }

    vim.ui.input(opts, function(choice)
        if not choice or choice == "n" then
            return
        end

        local job_rm = job.New({
            path = "rm",
            args = { "-r", "-f", node.abs_path },
        })
        job_rm:Run()
        if job_rm.status ~= 0 then
            utils.Notify("fail to remove " .. node.abs_path .. ", err: " .. job_rm.stderr)
            return
        end

        parent:Load()
    end)
    return true
end

function M.Refresh(node, renderer)
    renderer.tree:Load()
    return true
end

function M.CopyFileName(node)
    vim.fn.setreg("+", node.name)
    vim.fn.setreg('"', node.name)
    utils.Notify("Copy "..node.name.." to clipboard")
end

function M.CopyAbsPath(node)
    vim.fn.setreg("+", node.abs_path)
    vim.fn.setreg('"', node.abs_path)
    utils.Notify("Copy "..node.abs_path.." to clipboard")
end

function M.ToggleMark(node, renderer)
    if node == renderer.tree then
        return
    end

    local lnum = renderer.view.GetCursor()[1]
    local signs = renderer.view.GetSign(lnum)[1]
    log.debug("lnum: %s signs: %s\n", vim.inspect(lnum), vim.inspect(signs))
    if #signs.signs > 0 then
        renderer.view.ClearSign(signs.signs[1].id)
        for i, _ in ipairs(M.marks) do
            if M.marks[i] == node then
                table.remove(M.marks, i)
                break
            end
        end
    else
        renderer.view.SetSign("TTreeMark", lnum)
        table.insert(M.marks, node)
    end
    log.debug("marks: %s\n", vim.inspect(M.marks))
end

function M.MoveToParent(close)
    return function(node, renderer)
        if node == renderer.tree then
            return
        end

        local parent = node.parent

        for i, line in ipairs(renderer.lines) do
            if parent ==  line.node then
                renderer.view.SetCursor({i, 0})
            end
        end

        if close and node ~= renderer.tree then
            parent.status = "closed"
            return true
        end
    end
end

function M.MoveToLastChild(node, renderer)
    local cur_node = nil

    if (node.ftype == "folder" or (node.ftype == "link" and node.link_type == "folder")) and node.status == "opened" then
        cur_node = node
    else
        cur_node = node.parent
    end

    local last = cur_node.nodes[#cur_node.nodes]

    for i, line in ipairs(renderer.lines) do
        if last == line.node then
            renderer.view.SetCursor({i, 0})
        end
    end
end

function M.MoveToNextSibling(node, renderer)
    if node == renderer.tree then
        return
    end

    local parent = node.parent
    local next_node = nil

    for i, _ in ipairs(parent.nodes) do
        if parent.nodes[i] == node then
            next_node = i == #parent.nodes and parent.nodes[1] or parent.nodes[i + 1]
            break
        end
    end

    for i, line in ipairs(renderer.lines) do
        if next_node == line.node then
            renderer.view.SetCursor({i, 0})
        end
    end
end

function M.MoveToPrevSibling(node, renderer)
    if node == renderer.tree then
        return
    end

    local parent = node.parent
    local prev_node = nil

    for i, _ in ipairs(parent.nodes) do
        if parent.nodes[i] == node then
            prev_node = i == 1 and parent.nodes[#parent.nodes] or parent.nodes[i - 1]
            break
        end
    end

    for i, line in ipairs(renderer.lines) do
        if prev_node == line.node then
            renderer.view.SetCursor({i, 0})
        end
    end
end

function M.ToggleGitIgnoredFiles(node, renderer)
    if renderer.filter ~= nil then
        renderer.filter = nil
    else
        renderer.filter = require("ttree.filter").IsGitIgnored
    end
    return true
end

function M.ToggleDotFiles(node, renderer)
    if renderer.filter ~= nil then
        renderer.filter = nil
    else
        renderer.filter = require("ttree.filter").IsDotFile
    end
    return true
end

function M.ShowFileInfo(node, renderer)
    local fstat = node:FsStat()
    local context = {
        "Path: " .. node.abs_path,
        "Size: " .. utils.format_bytes(fstat.size),
        "CreateAt: " .. os.date("%x %X", fstat.birthtime.sec),
        "ModifiedAt: " .. os.date("%x %X", fstat.mtime.sec),
        "AccessedAt: " .. os.date("%x %X", fstat.atime.sec),
    }

    local win_width = vim.fn.max(vim.tbl_map(function(n) return #n end, context))
    local winnr = vim.api.nvim_open_win(0, false, {
        col = 1,
        row = 1,
        relative = "cursor",
        width = win_width + 1,
        height = #context,
        border = "shadow",
        noautocmd = true,
        style = "minimal",
    })
    M.finfo_win = { winnr = winnr, node = node }
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, context)
    vim.api.nvim_win_set_buf(winnr, bufnr)

    vim.cmd [[
        augroup TTreeCloseFileInfoWin
          au CursorMoved * lua require('ttree.actions')._CloseFileInfo()
        augroup END
    ]]
end

function M._CloseFileInfo()
    if M.finfo_win ~= nil then
        vim.api.nvim_win_close(M.finfo_win.winnr, { force = true })
        vim.cmd "augroup TTreeCloseFileInfoWin | au! CursorMoved | augroup END"
        M.finfo_win = nil
    end
end

function M.setup(opts)
    vim.fn.sign_define("TTreeMark", { text = "*" })
end

return M
