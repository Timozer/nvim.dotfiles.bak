local config = {}

function config.init()
    if packer_plugins["nvim-tree"] and packer_plugins["nvim-tree"].loaded then
        vim.cmd [[ packadd nvim-tree ]]
    end

    vim.g.nvim_tree_gitignore = 1
    vim.g.nvim_tree_indent_markers = 1
    vim.g.nvim_tree_git_hl = 1
    vim.g.nvim_tree_highlight_opened_files = 1
    vim.g.nvim_tree_root_folder_modifier = ':~'
    vim.g.nvim_tree_add_trailing = 1
    vim.g.nvim_tree_group_empty = 1
    vim.g.nvim_tree_disable_window_picker = 0
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
        }
    }
end

return config
