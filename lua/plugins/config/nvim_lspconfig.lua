local config = {}

local on_attach = function(client, bufnr)
end

function lsp_installer_init()
    local lsp_installer = require("nvim-lsp-installer")
    local path = require("nvim-lsp-installer.path")

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

        install_root_dir = path.concat { vim.fn.stdpath("data"), "lsp_servers" },

        pip = {
            -- Example: { "--proxy", "https://proxyserver" }
            install_args = {},
        },

        log_level = vim.log.levels.INFO,

        max_concurrent_installers = 4,
    })
end

function lsp_servers_init()
    local servers = require("nvim-lsp-installer.servers")
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

    local lsps = require('lsps')
    for name, config in pairs(lsps) do
        if config.enable then
            local ok, server = servers.get_server(name)
            if ok then
                config.opts.on_attach = on_attach 
                config.opts.capabilities = cpb
                config.opts.flags = { debounce_text_changes = 500 }
                server:on_ready(function() server:setup(config.opts) end)
                if not server:is_installed() then
                    server:install()
                end
            end
        end
    end
end

function config.init()
    if not packer_plugins["nvim-lspconfig"].loaded then
        vim.cmd [[packadd nvim-lspconfig]]
    end

    if not packer_plugins["nvim-lsp-installer"].loaded then
        vim.cmd [[packadd nvim-lsp-installer]]
    end

    lsp_installer_init()
    lsp_servers_init()
end

return config
