local utils = require('core.utils')

local basic_opts = {
    encoding="utf-8",
    fileencoding = "utf-8",
    fileencodings="utf-8,ucs-bom,gbk,cp936,gb2312,gb18030",
    scrolloff = 8,
    sidescrolloff = 8,
    number = true,
    relativenumber = true,
    signcolumn = "yes",
    background = "dark",
    termguicolors = true,
	cul = true,
	cuc = true,
	ruler = true,
	textwidth = 80,
	colorcolumn = "+1",
    smartindent=true,
    smarttab=true,
    joinspaces=false,
    wrap=false,
	tabstop = 4,
	shiftwidth = 4,
	softtabstop = 4,
	expandtab = true,
    completeopt="menu,menuone,noselect",
    sessionoptions="buffers,curdir,folds,options,localoptions,winsize,resize,winpos",
    autoread=true,
    cmdheight=2,
    laststatus=2,
    confirm=true,
    list=true,
    listchars="tab:› ,eol:↵,trail:•,extends:#,nbsp:.",
    splitright=true,
    backup=false,
    swapfile=false,
}

utils:bind_options(basic_opts)

vim.g.mapleader = ","
vim.g.maplocalleader = ","
vim.g.did_load_filetypes = 1

local basic_maps = {
	{
		mode = "n",
		key = "Y",
		cmd = "y$",
		options = {
			silent = false,
			noremap = false,
			nowait = false,
			expr = false,
		}
	},
	{
		mode = "n",
		key = "j",
		cmd = "gj",
		options = {
			silent = false,
			noremap = false,
			nowait = false,
			expr = false,
		}
	},
	{
		mode = "n",
		key = "k",
		cmd = "gk",
		options = {
			silent = false,
			noremap = false,
			nowait = false,
			expr = false,
		}
	},
	{
		mode = "n",
		key = "<leader>q",
		cmd = ":q<CR>",
		options = {
			silent = false,
			noremap = false,
			nowait = false,
			expr = false,
		}
	},
	{
		mode = "n",
		key = "<leader>w",
		cmd = ":w!<CR>",
		options = {
			silent = false,
			noremap = false,
			nowait = false,
			expr = false,
		}
	},
	{
		mode = "n",
		key = "Q",
		cmd = ":qa<CR>",
		options = {
			silent = false,
			noremap = false,
			nowait = false,
			expr = false,
		}
	},
	{
		mode = "n",
		key = "<leader>lw",
		cmd = "<C-W>l",
		options = {
			silent = false,
			noremap = true,
			nowait = false,
			expr = false,
		}
	},
	{
		mode = "n",
		key = "<leader>hw",
		cmd = "<C-W>h",
		options = {
			silent = false,
			noremap = true,
			nowait = false,
			expr = false,
		}
	},
	{
		mode = "n",
		key = "<leader>jw",
		cmd = "<C-W>j",
		options = {
			silent = false,
			noremap = true,
			nowait = false,
			expr = false,
		}
	},
	{
		mode = "n",
		key = "<leader>kw",
		cmd = "<C-W>k",
		options = {
			silent = false,
			noremap = true,
			nowait = false,
			expr = false,
		}
	},
	{
		mode = "n",
		key = "<C-Right>",
		cmd = ":vertical resize +10<CR>",
		options = {
			silent = false,
			noremap = true,
			nowait = false,
			expr = false,
		}
	},
	{
		mode = "n",
		key = "<C-Left>",
		cmd = ":vertical resize -10<CR>",
		options = {
			silent = false,
			noremap = true,
			nowait = false,
			expr = false,
		}
	},
	-- {
	-- 	mode = "n",
	-- 	key = "<C-Up>",
	-- 	cmd = ":resize -10<CR>",
	-- 	options = {
	-- 		silent = false,
	-- 		noremap = true,
	-- 		nowait = false,
	-- 		expr = false,
	-- 	}
	-- },
	-- {
	-- 	mode = "n",
	-- 	key = "<C-Down>",
	-- 	cmd = ":resize +10<CR>",
	-- 	options = {
	-- 		silent = false,
	-- 		noremap = true,
	-- 		nowait = false,
	-- 		expr = false,
	-- 	}
	-- },
}

utils:bind_keymaps(basic_maps)

-- local all_plgs = require('plugins')

-- for plugin, _ in pairs(all_plgs) do
  --   keymapfile = vim.fn.stdpath('config')..'/lua/plugins/keymap/'..plugin..'.lua'
    -- if (utils:file_exists(keymapfile)) then
      --   utils:bind_keymaps(require('plugins.keymap.'..plugin))
    -- end
-- end

vim.g.gpm_config = {
	log = {
		dir = vim.fn.stdpath("config") .. "/.cache/gpm/logs/",
		level = "debug", -- debug | info
	},
	plugin = {
		install_path = vim.fn.stdpath("config") .. "/pack/gpm/",
		compile_path = vim.fn.stdpath("config") .. "/plugin/gpm_compiled.lua",
		plugins = {
			{
				name = "nvim-lspconfig",
				type = "git", -- git | local | http
				path = "https://github.com/neovim/nvim-lspconfig",
				opt = false,
				event = {
					{ name = 'BufReadPre', pattern = "*" }
				},
				setup = function() 
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
					for _, item in ipairs(maps) do
						vim.api.nvim_set_keymap(item.mode, item.key, item.cmd, item.options)
					end
				end,
			},
			{
				name = "vim-easy-align",
				type = "git",
				path = "https://github.com/junegunn/vim-easy-align",
				opt = false,
				setup = function()
					vim.api.nvim_set_keymap("v", "<Enter>", ":EasyAlign<cr>", {noremap=false})
				end,
				event = {
					{ name = 'BurReadPre', pattern = "*" }
				}
			}
		}
	}
}

require('ctrlp_files').setup()
require('core.ctrlp').list_extensions()
