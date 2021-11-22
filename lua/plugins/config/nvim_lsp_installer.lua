local config = {}

local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
    -- Enable completion triggered by <c-x><c-o>
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
end

function config.init()
    local lsp_installer = require("nvim-lsp-installer")
    local path = require "nvim-lsp-installer.path"

    lsp_installer.settings({
        ui = {
            icons = {
                server_installed = "✓",
                server_pending = "➜",
                server_uninstalled = "✗"
            },
            keymaps = {
                -- Keymap to expand a server in the UI
                toggle_server_expand = "<CR>",
                -- Keymap to install a server
                install_server = "i",
                -- Keymap to reinstall/update a server
                update_server = "u",
                -- Keymap to uninstall a server
                uninstall_server = "X",
            },
        },

        -- The directory in which to install all servers.
        install_root_dir = path.concat { vim.fn.stdpath("data"), "lsp_servers" },

        pip = {
            -- Example: { "--proxy", "https://proxyserver" }
            install_args = {},
        },

        log_level = vim.log.levels.INFO,

        max_concurrent_installers = 4,
    })

    local servers = require "nvim-lsp-installer.servers"
    local lsps = require('lsps')
    for name, config in pairs(lsps) do
        if config.enable then
            local ok, server = servers.get_server(name)
            if ok then
                config.opts.on_attach = on_attach 
                server:on_ready(function() server:setup(config.opts) end)
                if not server:is_installed() then
                    server:install()
                end
            end
        end
    end
end

return config
