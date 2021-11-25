local maps = {
	{
		mode = "n",
		key = "<C-_>",
		cmd = ":CommentToggle<cr>",
		options = {
			noremap = true,
		}
	},
	{
		mode = "v",
		key = "<C-_>",
		cmd = ":'<,'>CommentToggle<cr>",
		options = {
			noremap = true,
		}
	},
}

return maps
