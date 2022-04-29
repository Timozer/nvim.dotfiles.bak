
local M = {}

function M.setup(opts)
    opts = opts or {}
    opts.log = {
        level = "debug",
        path = "ttree.log"
    }

    require("ttree.icons").setup(opts.icons)
    require("ttree.highlight").setup(opts.highlights)
    require("ttree.log").setup(opts.log)

    local log = require("ttree.log")
    local node = require("ttree.node")
    local tree = node.New()
    local view = require("ttree.view")
    view.Open()
    require("ttree.renderer").Draw(view, tree)
end

return M
