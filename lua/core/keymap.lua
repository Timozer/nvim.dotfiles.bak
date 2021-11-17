local keymap = {}

function keymap:bind(maps)
	for _, map in pairs(maps) do
		vim.api.nvim_set_keymap(map.mode, map.key, map.cmd, map.options)
	end
end

return keymap
