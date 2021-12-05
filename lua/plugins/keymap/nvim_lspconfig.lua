local maps = {
	{
		mode = "n",
		key = "gD",
		cmd = ":lua vim.lsp.buf.declaration()<cr>",
		options = {
			noremap = true,
            silent = true,
		}
	},
	{
		mode = "n",
		key = "gt",
		cmd = ":lua vim.lsp.buf.type_definition()<cr>",
		options = {
			noremap = true,
            silent = true,
		}
	},
	{
		mode = "n",
		key = "gd",
		cmd = ":lua vim.lsp.buf.definition()<cr>",
		options = {
			noremap = true,
            silent = true,
		}
	},
	{
		mode = "n",
		key = "gi",
		cmd = ":lua vim.lsp.buf.implementation()<cr>",
		options = {
			noremap = true,
            silent = true,
		}
	},
	{
		mode = "n",
		key = "gr",
		cmd = ":lua vim.lsp.buf.references()<cr>",
		options = {
			noremap = true,
            silent = true,
		}
	},
	{
		mode = "n",
		key = "[d",
		cmd = ":lua vim.diagnostic.goto_prev()<cr>",
		options = {
			noremap = true,
            silent = true,
		}
	},
	{
		mode = "n",
		key = "]d",
		cmd = ":lua vim.diagnostic.goto_next()<cr>",
		options = {
			noremap = true,
            silent = true,
		}
	},
	{
		mode = "n",
		key = "K",
		cmd = ":lua vim.lsp.buf.hover()<cr>",
		options = {
			noremap = true,
            silent = true,
		}
	},
	{
		mode = "n",
		key = "<C-k>",
		cmd = ":lua vim.lsp.buf.signature_help()<cr>",
		options = {
			noremap = true,
            silent = true,
		}
	},
	{
		mode = "n",
		key = "<leader>ca",
		cmd = ":lua vim.lsp.buf.code_action()<cr>",
		options = {
			noremap = true,
            silent = true,
		}
	},
	{
		mode = "n",
		key = "<leader>dl",
		cmd = ":lua vim.diagnostic.setloclist()<cr>",
		options = {
			noremap = true,
            silent = true,
		}
	},
	{
		mode = "n",
		key = "<S-F6>",
		cmd = ":lua vim.lsp.buf.rename()<cr>",
		options = {
			noremap = true,
            silent = true,
		}
	},
}

return maps
