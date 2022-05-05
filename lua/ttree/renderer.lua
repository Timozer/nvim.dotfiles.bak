
local log = require("ttree.log")
local utils = require("ttree.utils")
local icons = require("ttree.icons")

lines = {
    {
        line = "xxx",
        node = node,
        highlights = {}
    }
}

local M = {
    lines      = {},
    view       = nil,
    tree       = nil,
    gitstatus  = nil,
}

function M._RefreshGitStatus()
    M.gitstatus = nil
    local ret = require("ttree.git").Status(M.tree.abs_path)
    if ret.result == "success" then
        M.gitstatus = ret.data
    end
end

function M._RefreshLines()
    err = M.GetTreeContext(M.tree, 0)
    if err then
        -- TODO:
        log.error("Error: %s\n", vim.inspect(err))
        return
    end
    log.debug("lines: %s\n", vim.inspect(M.lines))

end

function M.GetRenderContext()
    local lines = {}
    local highlights = {}
    for i, item in ipairs(M.lines) do
        table.insert(lines, item.line)
        for _, highlight in pairs(item.highlights) do
            highlight[2] = i - 1
            table.insert(highlights, highlight)
        end
    end
    log.debug("lines: %s\n", vim.inspect(lines))
    log.debug("highlights: %s\n", vim.inspect(highlights))
    return lines, highlights
end

function M.Draw()
    if not M.tree or not M.view or not M.view.Visable() then
        return
    end

    M.lines = {}
    M.highlights = {}

    M._RefreshGitStatus()
    M._RefreshLines()

    local lines, highlights = M.GetRenderContext()
    M.view.Update(lines, highlights, M.keymaps['tree'])
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
        icon = node.link_type == "folder" and "" or ""
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

    local icon, icon_hl = M.GetNodeIcon(tree)
    icon = #icon > 0 and icon .. " " or ""

    local gitstatus, gitstatus_hl = M.GetGitIcon(tree)
    gitstatus = #gitstatus > 0 and " " .. gitstatus or ""

    local name = tree.name
    local name_hl = gitstatus_hl

    if M.tree == tree then
        icon = ""
        icon_hl = ""
        name = utils.path_join {
            utils.path_remove_trailing(vim.fn.fnamemodify(tree.abs_path, ":~")),
            "..",
        }
        name_hl = "TTreeRootFolder"
        gitstatus = ""
        gitstatus_hl = ""
    end

    local new_line = {
        line = string.format("%s%s%s%s", indent, icon, name, gitstatus),
        node = tree,
        highlights = {
            {icon_hl, -1, #indent, #indent + #icon},
            {name_hl, -1, #indent + #icon, #indent + #icon + #name},
            {gitstatus_hl, -1, #indent + #icon + #name, #indent + #icon + #name + #gitstatus},
        }
    }
    table.insert(M.lines, new_line)

    if tree.ftype == "folder" and tree.status == "opened" then
        for _, node in ipairs(tree.nodes) do
            M.GetTreeContext(node, depth + 1)
        end
    end

    return nil
end

function M.GetFocusedNode()
    local cursor = M.view.GetCursor()
    return M.lines[cursor[1]]["node"]
end

function M.DoAction(action)
    return function()
        local node = M.GetFocusedNode()
        local refresh = action(node, M)
        if refresh ~= nil and refresh == true then
            M.Draw()
        end
    end
end

function M.Toggle()
    if not M.view.Visable() then
        M.view.Open()
        M.Draw()
    else
        M.view.Close()
    end
end

function M.Focus()
    vim.api.nvim_set_current_win(M.view.GetWinnr())
end

function M.ShowTree(view, tree)
end

function M.ShowHelp(view)
end

function M.setup(opts)
    M.view = opts and opts.view
    M.tree = opts and opts.tree
    M.keymaps = opts and opts.keymaps
end

return M
