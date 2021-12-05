local config = {}

local on_attach = function(client, bufnr)
    -- local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    -- local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    -- Enable completion triggered by <c-x><c-o>
    -- buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    -- local opts = { noremap=true, silent=true }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    -- buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    -- buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    -- buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    -- buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    -- buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

    -- buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    -- buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    -- buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)

    -- buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    -- buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    -- buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    -- buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    -- buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    -- buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
    -- buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    -- buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
    -- buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

end

function config.init()
    local utils     = require('core.utils')
    local lunajson  = require('lunajson')
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
    local settings = lunajson.decode(data)
    local root = vim.fn.expand(settings.lsp.root)
    for server, cfg in pairs(settings.lsp.servers) do
        if cfg.enable then
            cfg.opts.on_attach = on_attach
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
end

return config
