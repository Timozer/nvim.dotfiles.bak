local view = require "ftree.view"
local filters = require "ftree.explorer.filters"
local renderer = require "ftree.renderer"
local reloaders = require "ftree.actions.reloaders"
local diagnostics = require "ftree.diagnostics"

local M = {}

function M.custom()
  filters.config.filter_custom = not filters.config.filter_custom
  return reloaders.reload_explorer()
end

function M.git_ignored()
  filters.config.filter_git_ignored = not filters.config.filter_git_ignored
  return reloaders.reload_explorer()
end

function M.dotfiles()
  filters.config.filter_dotfiles = not filters.config.filter_dotfiles
  return reloaders.reload_explorer()
end

function M.help()
  view.toggle_help()
  renderer.draw()
  if view.is_help_ui() then
    diagnostics.clear()
  else
    diagnostics.update()
  end
end

return M
