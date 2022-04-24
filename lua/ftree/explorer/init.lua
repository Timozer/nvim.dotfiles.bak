local uv = vim.loop

local git = require "ftree.git"

local M = {}

M.explore = require("ftree.explorer.explore").explore
M.reload = require("ftree.explorer.reload").reload

local Explorer = {}
Explorer.__index = Explorer

-- node:
--     cwd
--     nodes
--
--
--

function Explorer.new(cwd)
    cwd = uv.fs_realpath(cwd or uv.cwd())
    local explorer = setmetatable({cwd = cwd, nodes = {}}, Explorer)
    explorer:_load(explorer)
    return explorer
end

function Explorer:_load(node)
  local cwd = node.cwd or node.link_to or node.absolute_path
  local git_statuses = git.load_project_status(cwd)
  M.explore(node, git_statuses)
end

function Explorer:expand(node)
  self:_load(node)
end

function M.setup(opts)
  require("ftree.explorer.filters").setup(opts)
  require("ftree.explorer.sorters").setup(opts)
end

M.Explorer = Explorer

return M
