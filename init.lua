-- if not vim.g.vscode then require("core") end

local utils = require('core.utils')

local basic_opts = {
    termguicolors = true,
	cul = true,
	cuc = true,
	ruler = true,
	textwidth = 80,
	colorcolumn = "+1",
	tabstop = 4,
	shiftwidth = 4,
	softtabstop = 4,
	expandtab = true,
    number = true,
    completeopt="menu,menuone,noselect",
    sessionoptions="blank,buffers,curdir,folds,help,options,tabpages,winsize,resize,winpos,terminal",
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

