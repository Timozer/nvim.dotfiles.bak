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

function utils:dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. utils:dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

return utils
