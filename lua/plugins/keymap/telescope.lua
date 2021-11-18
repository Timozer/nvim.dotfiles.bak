local maps = {
	-- Telescope Keymaps
	{
		mode = "n",
		key = "<leader>ff",
		cmd = ":Telescope find_files<cr>",
		options = {
			noremap = true,
		}
	},
	{
		mode = "n",
		key = "<leader>fb",
		cmd = ":Telescope buffers<cr>",
		options = {
			noremap = true,
		}
	},
	{
		mode = "n",
		key = "<leader>fg",
		cmd = ":Telescope live_grep<cr>",
		options = {
			noremap = true,
		}
	},
	{
		mode = "n",
		key = "<leader>fh",
		cmd = ":Telescope help_tags<cr>",
		options = {
			noremap = true,
		}
	},
}

return maps
