local options = {}

function options:bind(opts)
	for key, val in pairs(opts) do
		vim.o[key] = val
	end
end

return options
