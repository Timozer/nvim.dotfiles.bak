vim.g.nvim_tree_gitignore = 1
vim.g.nvim_tree_indent_markers = 1
vim.g.nvim_tree_git_hl = 1
vim.g.nvim_tree_highlight_opened_files = 1
vim.g.nvim_tree_root_folder_modifier = ':~'
vim.g.nvim_tree_add_trailing = 1
vim.g.nvim_tree_group_empty = 1
vim.g.nvim_tree_disable_window_picker = 1
vim.g.nvim_tree_icon_padding = ' '
vim.g.nvim_tree_respect_buf_cwd = 1
vim.g.nvim_tree_create_in_closed_folder = 0
vim.g.nvim_tree_refresh_wait = 500

local tree_cb = require'nvim-tree.config'.nvim_tree_callback
require'nvim-tree'.setup {
    disable_netrw       = true,
    hijack_netrw        = true,
    open_on_setup       = false,
    ignore_ft_on_setup  = {},
    auto_close          = true,
    open_on_tab         = false,
    update_to_buf_dir   = {
        enable = false,
        auto_open = true,
    },
    hijack_cursor       = true,
    update_cwd          = false,
    update_focused_file = {
        enable      = false,
        update_cwd  = false,
        ignore_list = {}
    },
    system_open = {
        cmd  = nil,
        args = {}
    },
    diagnostics = {
        enable = true,
        icons = {
            hint = "",
            info = "",
            warning = "",
            error = "",
        }
    },
    filters = {
        dotfiles = false,
        custom = {}
    },
    view = {
        hide_root_folder = false,
        width = 30,
        height = 30,
        side = 'left',
        auto_resize = false,
        mappings = {
            custom_only = true,
            list = {
                { key = "i",    cb = tree_cb("cd") },
                { key = "o",                            cb = tree_cb("dir_up") },

                { key = "<CR>", cb = tree_cb("edit") },
                { key = "<C-]>",                        cb = tree_cb("vsplit") },
                { key = "<C-s>",                        cb = tree_cb("split") },

                { key = "<BS>",                         cb = tree_cb("close_node") },
                { key = "h",                            cb = tree_cb("parent_node") },
                { key = "K",                            cb = tree_cb("first_sibling") },
                { key = "J",                            cb = tree_cb("last_sibling") },

                { key = "H",                            cb = tree_cb("toggle_dotfiles") },
                { key = "R",                            cb = tree_cb("refresh") },
                -- { key = "<",                            cb = tree_cb("prev_sibling") },
                -- { key = ">",                            cb = tree_cb("next_sibling") },

                { key = "a",                            cb = tree_cb("create") },
                { key = "<Del>",                            cb = tree_cb("remove") },
                { key = "r",                            cb = tree_cb("rename") },
                { key = "<C-r>",                        cb = tree_cb("full_rename") },

                { key = "<C-x>",                            cb = tree_cb("cut") },
                { key = "<C-c>",                            cb = tree_cb("copy") },
                { key = "<C-v>",                            cb = tree_cb("paste") },

                { key = "y",                            cb = tree_cb("copy_name") },
                { key = "Y",                            cb = tree_cb("copy_path") },
                { key = "gy",                           cb = tree_cb("copy_absolute_path") },

                { key = "q",                            cb = tree_cb("close") },
                { key = "<C-_>",                           cb = tree_cb("toggle_help") },
            }
        }
    }
}

