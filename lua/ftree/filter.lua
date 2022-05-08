local M = {}


function M.IsDotFile(node)
    return node.name:sub(1, 1) == "."
end

function M.IsGitIgnored(node, gitstatus)
    local stat = M.gitstatus and M.gitstatus[node.abs_path] or nil
    return stat == "!!"
end

return M
