-- if not vim.g.vscode then require("core") end

local utils = require('core.utils')

local basic_opts = {
    background = "dark",
    termguicolors = true,
	cul = true,
	cuc = true,
	ruler = true,
	textwidth = 80,
	colorcolumn = "+1",
    smartindent=true,
    smarttab=true,
    nojoinspaces=true,
    wrap=true,
	tabstop = 4,
	shiftwidth = 4,
	softtabstop = 4,
	expandtab = true,
    number = true,
    completeopt="menu,menuone,noselect",
    sessionoptions="blank,buffers,curdir,folds,help,options,tabpages,winsize,resize,winpos,terminal",
    encoding="utf-8",
    termencoding="utf-8",
    fileencodings="utf-8,ucs-bom,gbk,cp936,gb2312,gb18030",
    scriptencoding="utf-8",
    autoread=true,
    novisualbell=true,
    cmdheight=2,
    laststatus=2,
    confirm=true,
    list=true,
    listchars="tab:›\ ,eol:↵,trail:•,extends:#,nbsp:.",
    splitright=true,
    noswapfile=true,
    backup=true,
}

utils:bind_options(basic_opts)

vim.g.mapleader = ","
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
}

utils:bind_keymaps(basic_maps)

local plugins = require('core.plugins')

local all_plgs = require('plugins')

plugins:load_plugins(all_plgs)

for plugin, _ in pairs(all_plgs) do
    -- cfgfile = vim.fn.stdpath('config')..'/lua/plugins/config/'..plugin..'.lua'
    -- if (utils:file_exists(cfgfile)) then
    --     require('plugins.config.'..plugin)
    -- end
    keymapfile = vim.fn.stdpath('config')..'/lua/plugins/keymap/'..plugin..'.lua'
    if (utils:file_exists(keymapfile)) then
        utils:bind_keymaps(require('plugins.keymap.'..plugin))
    end
end

