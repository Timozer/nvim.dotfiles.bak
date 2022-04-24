local a = vim.api

local lib = require "ftree.lib"
local log = require "ftree.log"
local view = require "ftree.view"

local M = {}

function M.do_action(action)
    local node = lib.get_node_at_cursor()
    if view.is_help_ui() then
        require('ftree.actions.toggles').help(node)
        return
    end
    if type(action) == "function" then
        action(node)
    elseif type(action) == "table" and action.do_action then
        action.do_action(node)
    end
end

function M.apply_mappings(bufnr)
    for _, b in pairs(M.keybindings) do
        local callback = b.action
        if type(callback) ~= "string" then
            log.line("config", "%s is not function\n", callback)
            goto continue
        end
        a.nvim_buf_set_keymap(
            bufnr, 
            b.mode or "n", 
            b.key, 
            string.format(":lua require('ftree.actions').do_action(%s)<CR>", callback), 
            { noremap = true, silent = true, nowait = true }
        )
        ::continue::
    end
end

function M.setup(opts)
    require("ftree.actions.system-open").setup(opts.system_open)
    require("ftree.actions.trash").setup(opts.trash)
    require("ftree.actions.open-file").setup(opts)
    require("ftree.actions.copy-paste").setup(opts)

    -- local options = vim.tbl_deep_extend("force", DEFAULT_MAPPING_CONFIG, user_map_config)
    M.keybindings = opts.keybindings or {
        { key = "i", action = "require('ftree.actions.dir').dir_in" },
        { key = "o", action = "require('ftree.actions.dir').dir_out" },

        { key = "<CR>", action = "require('ftree.actions.cr')" },
        { key = "<C-]>", action = "require('ftree.actions.file').vsplit" },
        { key = "<C-s>", action = "require('ftree.actions.file').split" },
        { key = "<C-p>", action = "require('ftree.actions.file').preview" },
        { key = "a", action = "require('ftree.actions.file').create" },

        { key = "<", action = "require('ftree.actions.movements').sibling(-1)" },
        { key = ">", action = "require('ftree.actions.movements').sibling(1)" },
        { key = "[[", action = "require('ftree.actions.movements').parent_node(false)" },
        { key = "<BS>", action = "require('ftree.actions.movements').parent_node(true)" },
        { key = "<Tab>", action = "require('ftree.actions.file').preview" },
        { key = "K", action = "require('ftree.actions.movements').sibling(-math.huge)" },
        { key = "J", action = "require('ftree.actions.movements').sibling(math.huge)" },
        { key = "I", action = "require('ftree.actions.toggles').git_ignored" },
        { key = "H", action = "require('ftree.actions.toggles').dotfiles" },
        { key = "R", action = "require('ftree.actions.reloaders').reload_explorer" },
        { key = "<Del>", action = "require('ftree.actions.remove-file').fn" },
        { key = "D", action = "require('ftree.actions.trash').fn" },
        { key = "r", action = "require(.ftree.actions.rename-file.).fn(false)" },

        { key = "<C-x>", action = "require('ftree.actions.copy-paste').cut" },
        { key = "<C-c>", action = "require('ftree.actions.copy-paste').copy" },
        { key = "<C-v>", action = "require('ftree.actions.copy-paste').paste" },

        { key = "y", action = "require('ftree.actions.copy-paste').copy_filename" },
        { key = "Y", action = "require('ftree.actions.copy-paste').copy_path" },
        { key = "gy", action = "require('ftree.actions.copy-paste').copy_absolute_path" },

        { key = "[c", action = "require('ftree.actions.movements').find_git_item 'prev'" },
        { key = "]c", action = "require('ftree.actions.movements').find_git_item 'next'" },
        { key = "s", action = "require('ftree.actions.system-open').fn" },
        { key = "q", action = "require('ftree.actions.close').do_action" },
        { key = "<C-_>", action = "require('ftree.actions.toggles').help" },
        { key = "W", action = "require('ftree.actions.collapse-all').fn" },
        { key = "S", action = "require('ftree.actions.search-node').fn" },
        { key = ".", action = "require('ftree.actions.run-command').run_file_command" },
        { key = "<C-k>", action = "require('ftree.actions.file-popup').toggle_file_info" },
        { key = "U", action = "require('ftree.actions.toggles').custom" },
    }

    log.line("config", "active keybindings")
    -- log.raw("config", "%s\n", vim.inspect(M.keybindings))
end

return M
