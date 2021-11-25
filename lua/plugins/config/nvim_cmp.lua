local config = {}

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

function config.init()
    if not packer_plugins["nvim-cmp"].loaded then
        vim.cmd [[packadd nvim-cmp]]
    end
    if not packer_plugins["LuaSnip"].loaded then
        vim.cmd [[packadd LuaSnip]]
    end
    if not packer_plugins["cmp_luasnip"].loaded then
        vim.cmd [[packadd cmp_luasnip]]
    end
    if not packer_plugins["cmp-buffer"].loaded then
        vim.cmd [[packadd cmp-buffer]]
    end
    if not packer_plugins["cmp-nvim-lsp"].loaded then
        vim.cmd [[packadd cmp-nvim-lsp]]
    end
    if not packer_plugins["cmp-path"].loaded then
        vim.cmd [[packadd cmp-path]]
    end
    if not packer_plugins["cmp-cmdline"].loaded then
        vim.cmd [[packadd cmp-cmdline]]
    end
    if not packer_plugins["lspkind-nvim"].loaded then
        vim.cmd [[packadd lspkind-nvim]]
    end

    local cmp = require'cmp'

    cmp.setup({
        snippet = {
            expand = function(args) require('luasnip').lsp_expand(args.body) end,
        },
        mapping = {
            ['<Tab>'] = cmp.mapping(function(fallback)
                local cmp = require('cmp')
                if cmp.visible() then
                    cmp.select_next_item()
                elseif require('luasnip').expand_or_jumpable() then
                    require('luasnip').expand_or_jump()
                else
                    vim.api.nvim_eval([[feedkeys("\<tab>", "n")]])
                    -- fallback()
                end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif require('luasnip').jumpable(-1) then
                    require('luasnip').jump(-1)
                else
                    fallback()
                end
            end, { "i", "s" }),
            ['<PageUp>']   = cmp.mapping(cmp.mapping.scroll_docs(-10), { 'i', 'c' }),
            ['<PageDown>'] = cmp.mapping(cmp.mapping.scroll_docs(10), { 'i', 'c' }),
            ['<CR>']       = cmp.mapping(function(fallback) 
                if cmp.visible() then
                    cmp.confirm({select = true})
                else
                    fallback()
                end
            end),
            -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
            ['<C-Space>']  = cmp.config.disable,
            ['<C-y>']      = cmp.config.disable,
            ['<C-e>']      = cmp.config.disable,
            ['<C-n>']      = cmp.config.disable,
            ['<C-p>']      = cmp.config.disable,
            ['<Down>']     = cmp.config.disable,
            ['<Up>']       = cmp.config.disable,
            ['<C-b>']      = cmp.config.disable,
            ['<C-f>']      = cmp.config.disable,
        },
        sources = cmp.config.sources({
            { name = 'luasnip' }, -- For luasnip users.
            { name = 'nvim_lsp' },
            { name = 'buffer' },
            { name = 'path' },
            { name = 'cmdline' },
        }),
        formatting = {
            format = require("lspkind").cmp_format({with_text = false, menu = ({
                buffer = "[Buf]",
                nvim_lsp = "[LSP]",
                luasnip = "[Snip]",
                latex_symbols = "[Tex]",
            })}),
        }
    })

    -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline('/', {
        sources = {
            { name = 'buffer' }
        }
    })

    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(':', {
        sources = cmp.config.sources({
            { name = 'path' }
        }, {
            { name = 'cmdline' }
        })
    })
end

return config
