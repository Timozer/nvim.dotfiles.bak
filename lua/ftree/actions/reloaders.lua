local git = require "ftree.git"
local diagnostics = require "ftree.diagnostics"
local view = require "ftree.view"
local renderer = require "ftree.renderer"
local explorer_module = require "ftree.explorer"
local core = require "ftree.core"

local M = {}

local function refresh_nodes(node, projects)
  local cwd = node.cwd or node.link_to or node.absolute_path
  local project_root = git.rootpath(cwd)
  explorer_module.reload(node, projects[project_root] or {})
  for _, _node in ipairs(node.nodes) do
    if _node.nodes and _node.open then
      refresh_nodes(_node, projects)
    end
  end
end

function M.reload_node_status(parent_node, projects)
  local project_root = git.rootpath(parent_node.absolute_path or parent_node.cwd)
  local status = projects[project_root] or {}
  for _, node in ipairs(parent_node.nodes) do
    if node.nodes then
      node.git_status = status.dirs and status.dirs[node.absolute_path]
    else
      node.git_status = status.files and status.files[node.absolute_path]
    end
    if node.nodes and #node.nodes > 0 then
      M.reload_node_status(node, projects)
    end
  end
end

local event_running = false
function M.reload_explorer()
  if event_running or not core.get_explorer() or vim.v.exiting ~= vim.NIL then
    return
  end
  event_running = true

  local projects = git.reload()
  refresh_nodes(core.get_explorer(), projects)
  if view.is_visible() then
    renderer.draw()
  end
  diagnostics.update()
  event_running = false
end

function M.reload_git()
  if not core.get_explorer() or not git.config.enable or event_running then
    return
  end
  event_running = true

  local projects = git.reload()
  M.reload_node_status(core.get_explorer(), projects)
  renderer.draw()
  event_running = false
end

return M
