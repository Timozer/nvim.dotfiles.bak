local M = {}

function M.Sync()
end

function M.Clean()
    -- code
end

function M.Status()
    -- code
end

function M.ProfileOutput()
    -- code
end

local opts = {
    plugins = {
        git = {
            edge = {
                name = 'edge',
                'edge',
                config = nil,
            }
        },
    }
}

function M.SetUp(opts)
    opts = opts or {}
    M.plugins = opts.plugins or {}

    vim.cmd [[command! PmgSync  lua require('pmg').Sync()]]
    vim.cmd [[command! PmgStatus  lua require('pmg').Status()]]
    vim.cmd [[command! PmgProfile lua require('pmg').ProfileOutput()]]
end

return M
