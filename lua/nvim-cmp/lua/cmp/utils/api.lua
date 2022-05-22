local api = {}

api.is_suitable_mode = function()
  local mode = api.get_mode()
  return mode == 'i' or mode == 'c'
end

api.get_screen_cursor = function()
  if api.is_cmdline_mode() then
    local cursor = api.get_cursor()
    return { cursor[1], cursor[2] + 1 }
  end
  local cursor = api.get_cursor()
  local pos = vim.fn.screenpos(0, cursor[1], cursor[2] + 1)
  return { pos.row, pos.col - 1 }
end

return api
