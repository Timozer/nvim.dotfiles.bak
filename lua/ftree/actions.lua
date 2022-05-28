local utils = require('ftree.utils')
local job = require('ftree.job')
local log = require('ftree.log')
local buf = require('lib.buf')

local M = {
    finfo_win = nil,
    marks = {},
    action = {
        type = nil,
        data = {}
    },
    action_info_win = nil,
}

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
    if node.ftype == "link" and node.link_type ~= "file" or node.ftype ~= "file" then
        return
    end

    vim.api.nvim_command("wincmd p")
    pcall(vim.cmd, "edit "..vim.fn.fnameescape(node.ftype == "link" and node.link_to or node.abs_path))
end

function M.SplitFile(node)
    if node.ftype == "link" and node.link_type ~= "file" or node.ftype ~= "file" then
        return
    end

    vim.api.nvim_command("wincmd p")
    pcall(vim.cmd, "sp "..vim.fn.fnameescape(node.ftype == "link" and node.link_to or node.abs_path))
end

function M.VSplitFile(node)
    if node.ftype == "link" and node.link_type ~= "file" or node.ftype ~= "file" then
        return
    end

    vim.api.nvim_command("wincmd p")
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
        local tree = require("ftree.node").New({
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

        old_path = node.abs_path
        node.name = fname
        node.abs_path = abs_path
        if node.ftype == "folder" or (node.ftype == "link" and node.link_type == "folder") then
            node.nodes = {}
            if node.status == "opened" then
                node:Expand()
            end
        end

        if node.ftype == "folder" then
            buf.RenameBufByNamePrefix(old_path .. "/", node.abs_path .. "/")
        else
            buf.RenameBufByNamePrefix(old_path, node.abs_path)
        end

    end)
    return true
end

function M.RemoveFile(node, renderer)
    if node == renderer.tree then
        utils.Notify("cannot remove root folder")
        return
    end

    local resp = utils.GetInputChar("Delete " .. node.abs_path .. " ? [y/n] ")
    if resp ~= "y" then
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

    rm_path = node.abs_path
    if node.ftype == "folder" then
        rm_path = rm_path .. "/"
    end

    buf.DelBufByNamePrefix(rm_path, true)

    node.parent:Load()
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
    if #signs.signs > 0 then
        renderer.view.ClearSign(signs.signs[1].id)
        for i, _ in ipairs(M.marks) do
            if M.marks[i] == node then
                table.remove(M.marks, i)
                break
            end
        end
    else
        renderer.view.SetSign("FTreeMark", lnum)
        table.insert(M.marks, node)
    end
end

function M.Copy(node, renderer)
    M.action.type = "copy"
    if #M.marks > 0 then
        M.action.data = M.marks
        M.marks = {}
        renderer.view.ClearSign()
    else
        M.action.data = {}
        table.insert(M.action.data, node)
    end
end

function M.Cut(node, renderer)
    M.action.type = "cut"
    if #M.marks > 0 then
        M.action.data = M.marks
        M.marks = {}
        renderer.view.ClearSign()
    else
        M.action.data = {}
        table.insert(M.action.data, node)
    end
end

function M.Paste(node, renderer)
    if not (#M.action.data > 0) then
        return
    end

    local paste_to = node
    if node.ftype == "file" or (node.ftype == "link" and node.ftype == "file") then
        paste_to = node.parent
    end

    local cmd = nil
    local args = nil
    if M.action.type == "cut" then
        cmd = "mv"
        args = {}
    elseif M.action.type == "copy" then
        cmd = "cp"
        args = { "-rf" }
    else
        return
    end

    local idx = 1
    while idx <= #M.action.data do
        log.debug("idx: %d, paste: %s\n", idx, M.action.data[idx].abs_path)
        local dst = utils.path_join({paste_to.abs_path, M.action.data[idx].name})

        while true do
            if not utils.file_exists(dst) then
                break
            end

            local resp = utils.GetInputChar(dst .. " exists, rename/overwrite/cancel? [r/o/c] ")
            if resp == "r" then
                local opts = { 
                    prompt = "Rename " .. M.action.data[idx].abs_path .. " to: ",
                    default = dst,
                }
                vim.ui.input(opts, function(fname)
                    if fname == nil or #fname == 0 then
                        dst = ""
                        return
                    end
                    dst = fname
                end)
                if dst == "" then
                    goto continue
                end
            elseif resp == "o" then
                break
            else
                goto continue
            end
        end

        tmpArgs = { M.action.data[idx].abs_path, dst }
        for j, aval in ipairs(args) do
            table.insert(tmpArgs, j, aval)
        end
        job_paste = job.New({path = cmd, args = tmpArgs})
        job_paste:Run()
        if job_paste.status ~= 0 then
            msg = "paste: " .. M.action.data[idx].abs_path .. " to " .. dst .. " fail, err: " .. job_paste.stderr
            utils.Notify(msg)
            log.debug(msg)
            break
        end
        msg = "paste " .. M.action.data[idx].abs_path .. " to " .. dst .. " done"
        utils.Notify(msg)
        log.debug(msg)

        if M.action.data[idx].ftype == "folder" then
            buf.RenameBufByNamePrefix(M.action.data[idx].abs_path .. "/", dst .. "/")
        else
            buf.RenameBufByNamePrefix(M.action.data[idx].abs_path, dst)
        end

        ::continue::

        table.remove(M.action.data, idx)
    end

    renderer.tree:Load()
    return true
end

function M.ShowActionInfo(node, renderer)
    local context = {
        "Action Type: " .. vim.inspect(M.action.type),
        "Data: ",
    }

    for i, val in ipairs(M.action.data) do
        table.insert(context, val.abs_path)
    end

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
    M.action_info_win = { winnr = winnr, node = node }
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, context)
    vim.api.nvim_win_set_buf(winnr, bufnr)

    vim.cmd [[
        augroup FTreeCloseActionInfoWin
          au CursorMoved * lua require('ftree.actions')._CloseActionInfo()
        augroup END
    ]]
end

function M._CloseActionInfo()
    if M.action_info_win ~= nil then
        vim.api.nvim_win_close(M.action_info_win.winnr, { force = true })
        vim.cmd "augroup FTreeCloseActionInfoWin | au! CursorMoved | augroup END"
        M.action_info_win = nil
    end
end

function M.ClearMarks(node, renderer)
    renderer.view.ClearSign()
    M.marks = {}
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
        renderer.filter = require("ftree.filter").IsGitIgnored
    end
    return true
end

function M.ToggleDotFiles(node, renderer)
    if renderer.filter ~= nil then
        renderer.filter = nil
    else
        renderer.filter = require("ftree.filter").IsDotFile
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
        augroup FTreeCloseFileInfoWin
          au CursorMoved * lua require('ftree.actions')._CloseFileInfo()
        augroup END
    ]]
end

function M._CloseFileInfo()
    if M.finfo_win ~= nil then
        vim.api.nvim_win_close(M.finfo_win.winnr, { force = true })
        vim.cmd "augroup FTreeCloseFileInfoWin | au! CursorMoved | augroup END"
        M.finfo_win = nil
    end
end

function M.setup(opts)
    vim.fn.sign_define("FTreeMark", { text = "*" })
end

return M
