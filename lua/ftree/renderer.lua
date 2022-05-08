
local log = require("ftree.log")
local utils = require("ftree.utils")
local icons = require("ftree.icons")

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
    lines      = nil,
    gitstatus  = nil,
    filter     = nil,
}

function M._RefreshGitStatus()
    M.gitstatus = nil
    local ret = require("ftree.git").Status(M.tree.abs_path)
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
        hl = node.status == "closed" and "FTreeFolderClosed" or "FTreeFolderOpened"
    elseif node.ftype == "link" then
        icon = node.link_type == "folder" and "" or ""
        hl = node.link_type == "folder" and "FTreeSymlinkFolder" or "FTreeSymlinkFile"
    end
    return icon, hl
end

-- local gitIcons = {
--     ["M "] = { { "[M]", "FTreeGitStaged" } },
--     [" M"] = { { "[M]", "FTreeGitModified" } },
--     ["C "] = { { icon = i.staged, hl = "NvimTreeGitStaged" } },
--     [" C"] = { { icon = i.unstaged, hl = "NvimTreeGitDirty" } },
--     ["CM"] = { { icon = i.unstaged, hl = "NvimTreeGitDirty" } },
--     [" T"] = { { icon = i.unstaged, hl = "NvimTreeGitDirty" } },
--     ["T "] = { { icon = i.staged, hl = "NvimTreeGitStaged" } },
--     ["MM"] = {
--         { icon = i.staged, hl = "NvimTreeGitStaged" },
--         { icon = i.unstaged, hl = "NvimTreeGitDirty" },
--     },
--     ["MD"] = {
--         { icon = i.staged, hl = "NvimTreeGitStaged" },
--     },
--     ["A "] = {
--         { icon = i.staged, hl = "NvimTreeGitStaged" },
--     },
--     ["AD"] = {
--         { icon = i.staged, hl = "NvimTreeGitStaged" },
--     },
--     [" A"] = {
--         { icon = i.untracked, hl = "NvimTreeGitNew" },
--     },
--     -- not sure about this one
--     ["AA"] = {
--         { icon = i.unmerged, hl = "NvimTreeGitMerge" },
--         { icon = i.untracked, hl = "NvimTreeGitNew" },
--     },
--     ["AU"] = {
--         { icon = i.unmerged, hl = "NvimTreeGitMerge" },
--         { icon = i.untracked, hl = "NvimTreeGitNew" },
--     },
--     ["AM"] = {
--         { icon = i.staged, hl = "NvimTreeGitStaged" },
--         { icon = i.unstaged, hl = "NvimTreeGitDirty" },
--     },
--     ["??"] = { { icon = i.untracked, hl = "NvimTreeGitNew" } },
--     ["R "] = { { icon = i.renamed, hl = "NvimTreeGitRenamed" } },
--     [" R"] = { { icon = i.renamed, hl = "NvimTreeGitRenamed" } },
--     ["RM"] = {
--         { icon = i.unstaged, hl = "NvimTreeGitDirty" },
--         { icon = i.renamed, hl = "NvimTreeGitRenamed" },
--     },
--     ["UU"] = { { icon = i.unmerged, hl = "NvimTreeGitMerge" } },
--     ["UD"] = { { icon = i.unmerged, hl = "NvimTreeGitMerge" } },
--     ["UA"] = { { icon = i.unmerged, hl = "NvimTreeGitMerge" } },
--     [" D"] = { { icon = i.deleted, hl = "NvimTreeGitDeleted" } },
--     ["D "] = { { icon = i.deleted, hl = "NvimTreeGitDeleted" } },
--     ["RD"] = { { icon = i.deleted, hl = "NvimTreeGitDeleted" } },
--     ["DD"] = { { icon = i.deleted, hl = "NvimTreeGitDeleted" } },
--     ["DU"] = {
--         { icon = i.deleted, hl = "NvimTreeGitDeleted" },
--         { icon = i.unmerged, hl = "NvimTreeGitMerge" },
--     },
--     ["!!"] = { { icon = i.ignored, hl = "NvimTreeGitIgnored" } },
-- }

function M.GetGitIcon(node)
    local stat = M.gitstatus and M.gitstatus[node.abs_path] or nil
    if stat == nil then
        return "", ""
    end
    if stat == "M " then
        return "[M]", "FTreeGitStaged"
    elseif stat == " M" then
        return "[M]", "FTreeGitModified"
    elseif stat == "R " or stat == " R" then
        return "[R]", "FTreeGitRenamed"
    elseif stat == " A" then
        return "[A]", "FTreeGitAdded"
    elseif stat == "??" then
        return "[★]", "FTreeGitUntracked"
    elseif stat == "!!" then
        return "[◌]", "FTreeGitIgnored"
    end
    return "", ""
end

-- indent : icon : filename : gitstatus
function M.GetTreeContext(tree, depth)
    if M.filter and M.filter(tree, M.gitstatus) then
        return
    end

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
        name_hl = "FTreeRootFolder"
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
