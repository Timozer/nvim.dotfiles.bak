
local log = require("ttree.log")
local utils = require("ttree.utils")
local icons = require("ttree.icons")

local M = {
    lines = {},
    highlights = {},
    curlineno = 0,
}

function M.Draw(view, tree)
    if not tree or not view or not view.Visable() then
        return
    end

    M.lines = {}
    M.highlights = {}
    M.curlineno = 0

    local gitstatus = require("ttree.git").Status(tree.abs_path)
    if gitstatus.result == "success" then
        M.gitstatus = gitstatus.data
    end

    err = M.GetTreeContext(tree, 0)
    if err then
        -- TODO:
        log.error("Error: %s\n", vim.inspect(err))
        return
    end

    view.Update(M.lines, M.highlights)
end

function M.GetNodeIcon(node)
    local icon = " "
    local hl = ""
    if node.ftype == "file" then
        icon, hl = icons.GetIcon(node.name)
    elseif node.ftype == "folder" then
        icon = node.status == "closed" and "" or ""
        hl = node.status == "closed" and "TTreeFolderClosed" or "TTreeFolderOpened"
    elseif node.ftype == "link" then
        icon = node.link_type == "folder" and "" or "➜"
        hl = node.link_type == "folder" and "TTreeSymlinkFolder" or "TTreeSymlinkFile"
    end
    return icon, hl
end

function M.GetGitIcon(node)
    local stat = M.gitstatus and M.gitstatus[node.abs_path] or nil
    if stat == nil then
        return "", ""
    end
    if stat == "M " then
        return "[M]", "TTreeGitStaged"
    elseif stat == " M" then
        return "[M]", "TTreeGitModified"
    elseif stat == "R " then
        return "[R]", "TTreeGitRenamed"
    elseif stat == " A" then
        return "[A]", "TTreeGitAdded"
    elseif stat == "??" then
        return "[★]", "TTreeGitUntracked"
    elseif stat == "!!" then
        return "[◌]", "TTreeGitIgnored"
    end
    return "", ""
end

-- indent : icon : filename : gitstatus
function M.GetTreeContext(tree, depth)
    log.debug("abs_path: %s ftype: %s\n", tree.abs_path, tree.ftype)

    local indent = string.rep(" ", depth * 2)
    if depth > 0 then
        table.insert(M.highlights, {"TTreeIndentMarker", M.curlineno, 0, string.len(indent)})
    end

    local icon, icon_hl = M.GetNodeIcon(tree)
    icon = #icon > 0 and icon .. " " or ""

    local name = tree.name

    local gitstatus, gitstatus_hl = M.GetGitIcon(tree)
    gitstatus = #gitstatus > 0 and " " .. gitstatus or ""

    local name_hl = gitstatus_hl

    if M.curlineno == 0 then
        icon = ""
        icon_hl = ""
        name = utils.path_join {
            utils.path_remove_trailing(vim.fn.fnamemodify(tree.abs_path, ":~")),
            "..",
        }
        name_hl = "TTreeRootFolder"
        gitstatus = ""
        gitstatus_hl = ""
    elseif tree.ftype == "file" then
    elseif tree.ftype == "folder" then
    elseif tree.ftype == "link" then
    end

    local line = string.format("%s%s%s%s", indent, icon, name, gitstatus)
    table.insert(M.lines, line)
    table.insert(M.highlights, {icon_hl, M.curlineno, #indent, #indent + #icon})
    table.insert(M.highlights, {name_hl, M.curlineno, #indent + #icon, #indent + #icon + #name})
    table.insert(M.highlights, {gitstatus_hl, M.curlineno, #indent + #icon + #name, #indent + #icon + #name + #gitstatus})

    M.curlineno = M.curlineno + 1
    if tree.ftype == "folder" and tree.status == "opened" then
        for _, node in ipairs(tree.nodes) do
            M.GetTreeContext(node, depth + 1)
        end
    end

    return nil
end

function M.ShowTree(view, tree)
end

function M.ShowHelp(view)
end

return M
