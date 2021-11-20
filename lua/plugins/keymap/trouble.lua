local maps = {
	{
		mode = "n",
		key = "<leader>tt",
		cmd = ":TroubleToggle<cr>",
		options = {
			noremap = true,
		}
	},
	{
		mode = "n",
		key = "<leader>tq",
		cmd = ":TroubleToggle quickfix<cr>",
		options = {
			noremap = true,
		}
	},
	{
		mode = "n",
		key = "<leader>tl",
		cmd = ":TroubleToggle loclist<cr>",
		options = {
			noremap = true,
		}
	},
	{
		mode = "n",
		key = "<leader>tr",
		cmd = ":TroubleToggle lsp_references<cr>",
		options = {
			noremap = true,
		}
	},
}

return maps
