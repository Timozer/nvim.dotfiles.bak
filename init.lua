-- if not vim.g.vscode then require("core") end

local options = require('core.options')

local basic_opts = {
	cul = true,
	cuc = true,
	ruler = true,
	textwidth = 80,
	colorcolumn = "+1",
	tabstop = 4,
	shiftwidth = 4,
	softtabstop = 4,
	expandtab = true,
}

options:bind(basic_opts)

local plugins = require('core.plugins')

function all_plugins(use)
	use 'wbthomason/packer.nvim'
	use {
		'nvim-telescope/telescope.nvim',
		requires = { {'nvim-lua/plenary.nvim'} }
	}
end

plugins:start(all_plugins)

local actions = require('telescope.actions')

require('telescope').setup{
	defaults = {
		mappings = {
			i = {
				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,

				["<C-c>"] = actions.close,

				["<CR>"] = actions.select_default,
				["<C-s>"] = actions.select_horizontal,
				["<C-v>"] = actions.select_vertical,

				["<PageUp>"] = actions.preview_scrolling_up,
				["<PageDown>"] = actions.preview_scrolling_down,

				["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
				["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
				["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
				["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
				["<C-l>"] = actions.complete_tag,
			},

			n = {
				["<esc>"] = actions.close,
				["<CR>"] = actions.select_default,
				["<C-s>"] = actions.select_horizontal,
				["<C-v>"] = actions.select_vertical,

				["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
				["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
				["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
				["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

				-- TODO: This would be weird if we switch the ordering.
				["j"] = actions.move_selection_next,
				["k"] = actions.move_selection_previous,
				["H"] = actions.move_to_top,
				["M"] = actions.move_to_middle,
				["L"] = actions.move_to_bottom,
				["gg"] = actions.move_to_top,
				["G"] = actions.move_to_bottom,

				["<PageUp>"] = actions.preview_scrolling_up,
				["<PageDown>"] = actions.preview_scrolling_down,

				["?"] = actions.which_key,
			},
		}
	}
}

vim.g.mapleader = ","

local keymap = require('core.keymap')

local maps = {
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

keymap:bind(maps)
