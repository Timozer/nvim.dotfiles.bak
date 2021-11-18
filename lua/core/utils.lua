local utils = {}

function utils:bind_options(opts)
	for key, val in pairs(opts) do
		vim.o[key] = val
	end
end

function utils:bind_keymaps(maps)
	for _, map in pairs(maps) do
		vim.api.nvim_set_keymap(map.mode, map.key, map.cmd, map.options)
	end
end

function utils:file_exists(path)
  local file = io.open(path, "rb")
  if file then file:close() end
  return file ~= nil
end

return utils
