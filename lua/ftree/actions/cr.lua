
local lib = require "ftree.lib"
local M = {}

function M.do_action(node)
    if not node or node.name == ".." then
        return
    end

    if not node.nodes then
        if node.link_to then
            require("ftree.actions.open-file").fn("edit", node.link_to)
        else
            require("ftree.actions.open-file").fn("edit", node.absolute_path)
        end
    end
    if node.nodes ~= nil then
        lib.expand_or_collapse(node)
    end
end

return M
