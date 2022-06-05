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
		install_path = vim.fn.stdpath("config") .. "/pack/",
		compile_path = vim.fn.stdpath("config") .. "/plugin/gpm_compiled.lua",
		plugins = {
			{
				type = "git",
				path = "https://github.com/nathom/filetype.nvim",
				opt = false,
				setup = function()
				end
			},
			{
				type = "git",
				path = "https://github.com/sainnhe/edge",
				opt = false,
				setup = function()
					vim.cmd [[set background=dark]]
					vim.g.edge_style = "aura"
					vim.g.edge_enable_italic = 1
					vim.g.edge_disable_italic_comment = 1
					vim.g.edge_show_eob = 1
					vim.g.edge_better_performance = 1

					vim.cmd [[ colorscheme edge ]]
				end
			},
			{
				type = "git", -- git | local | http
				path = "https://github.com/neovim/nvim-lspconfig",
				opt = false,
				event = {
					{ name = 'BufReadPre', pattern = "*" }
				},
				setup = function() 
                    vim.api.nvim_set_keymap("n", "gD", ":lua vim.lsp.buf.declaration()<cr>", {noremap=true, silent=true})
                    vim.api.nvim_set_keymap("n", "gt", ":lua vim.lsp.buf.type_definition()<cr>", {noremap=true, silent=true})
                    vim.api.nvim_set_keymap("n", "gd", ":lua vim.lsp.buf.definition()<cr>", {noremap=true, silent=true})
                    vim.api.nvim_set_keymap("n", "gi", ":lua vim.lsp.buf.implementation()<cr>", {noremap=true, silent=true})
                    vim.api.nvim_set_keymap("n", "gr", ":lua vim.lsp.buf.references()<cr>", {noremap=true, silent=true})
                    vim.api.nvim_set_keymap("n", "[d", ":lua vim.diagnostic.goto_prev()<cr>", {noremap=true, silent=true})
                    vim.api.nvim_set_keymap("n", "]d", ":lua vim.diagnostic.goto_next()<cr>", {noremap=true, silent=true})
                    vim.api.nvim_set_keymap("n", "K", ":lua vim.lsp.buf.hover()<cr>", {noremap=true, silent=true})
                    vim.api.nvim_set_keymap("n", "<C-k>", ":lua vim.lsp.buf.signature_help()<cr>", {noremap=true, silent=true})
                    vim.api.nvim_set_keymap("n", "<leader>ca", ":lua vim.lsp.buf.code_action()<cr>", {noremap=true, silent=true})
                    vim.api.nvim_set_keymap("n", "<leader>dl", ":lua vim.diagnostic.setloclist()<cr>", {noremap=true, silent=true})
                    vim.api.nvim_set_keymap("n", "<S-F6>", ":lua vim.lsp.buf.rename()<cr>", {noremap=true, silent=true})

					local utils     = require('core.utils')
					local lspconfig = require('lspconfig')
					local cpb = vim.lsp.protocol.make_client_capabilities()

					cpb.textDocument.completion.completionItem.documentationFormat = {
						"markdown", "plaintext"
					}
					cpb.textDocument.completion.completionItem.snippetSupport = true
					cpb.textDocument.completion.completionItem.preselectSupport = true
					cpb.textDocument.completion.completionItem.insertReplaceSupport = true
					cpb.textDocument.completion.completionItem.labelDetailsSupport = true
					cpb.textDocument.completion.completionItem.deprecatedSupport = true
					cpb.textDocument.completion.completionItem.commitCharactersSupport = true
					cpb.textDocument.completion.completionItem.tagSupport = {
						valueSet = {1}
					}
					cpb.textDocument.completion.completionItem.resolveSupport = {
						properties = {"documentation", "detail", "additionalTextEdits"}
					}

					local data = utils:file_read(vim.fn.stdpath('config')..'/settings.json')
					local settings = vim.json.decode(data)
					local root = vim.fn.expand(settings.lsp.root)
					for server, cfg in pairs(settings.lsp.servers) do
						if cfg.enable then
							cfg.opts.capabilities = cpb
							cfg.opts.flags = { debounce_text_changes = 500 }
							if cfg.opts['cmd'] then
								if utils:startswith(cfg.opts.cmd[1], '#') then
									cfg.opts.cmd[1] = root..'/'..server..'/'..string.sub(cfg.opts.cmd[1], 2)
								end
							end
							lspconfig[server].setup(cfg.opts)
						end
					end
				end,
			},
			{
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
