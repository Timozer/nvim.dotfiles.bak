local plugins = {
    packer = { 'packer.nvim' },
    startuptime = {
        'vim-startuptime',
        opt = true,
        cmd = 'StartupTime',
    },
    filetype = {
        'filetype.nvim'
    },
    -- display
    edge = {
        'edge',
        config = require('plugins.config.edge').init,
    },
    gitsigns = {
        'gitsigns.nvim',
        opt = true,
        event = {'BufRead', 'BufNewFile' },
        requires = {'plenary.nvim', opt=true,},
        config = require('plugins.config.gitsigns').init
    },
    indent_blankline = {
        'indent-blankline.nvim',
        opt = true,
        event = 'BufRead',
        config = require('plugins.config.indent_blankline').init
    },
    nui_nvim = {
        'nui.nvim'
    },
    -- editor
    vim_easy_align = {
        'vim-easy-align',
        opt = true,
        cmd = 'EasyAlign',
    },
    -- float windows
    telescope = {
        'telescope.nvim',
        opt = true,
        cmd = 'Telescope',
        requires = { {'plenary.nvim'} },
        config = require('plugins.config.telescope').init
    },
    telescope_fzf_native = {
        'telescope-fzf-native.nvim',
        opt = true,
        after = "telescope.nvim",
        run = 'make',
        config = require('plugins.config.telescope_fzf_native').init
    },
    -- symbols explorer
    symbols_outline = {
        'symbols-outline.nvim',
        opt = true,
        cmd = {'SymbolsOutline', 'SymbolsOutlineOpen' },
        config = require('plugins.config.symbols_outline').init
    },
    -- lsp
    nvim_lspconfig = {
        "nvim-lspconfig",
        opt = true,
        event = 'BufReadPre',
        config = require('plugins.config.nvim_lspconfig').init
    },
    nvim_lightbulb = {
        'nvim-lightbulb',
        opt = true,
        after = 'nvim-lspconfig',
        config = require('plugins.config.nvim_lightbulb').init
    },
    --lspsaga = {
        --'lspsaga.nvim',
        --after = 'nvim-lspconfig',
        --config = require('plugins.config.lspsaga').init
    --},
    luasnip = {
        'LuaSnip',
        -- opt = true,
        -- after = 'nvim-cmp',
        requires = { 'friendly-snippets' },
        config = function()
            if not packer_plugins["LuaSnip"].loaded then
                vim.cmd [[packadd LuaSnip]]
            end
            if not packer_plugins["friendly-snippets"].loaded then
                vim.cmd [[packadd friendly-snippets]]
            end
            require('luasnip').config.set_config {
                history = true,
                updateevents = "TextChanged,TextChangedI"
            }
            require("luasnip/loaders/from_vscode").load()
        end
    },
    lspkind = {
        'lspkind-nvim'
    },
    -- nvim_cmp = {
    --     'nvim-cmp',
    --     -- opt = true,
    --     -- event = { 'InsertEnter' },
    --     after = 'lspkind-nvim',
    --     requires = {
    --         {'cmp_luasnip', after = 'LuaSnip'},
    --         {'cmp-buffer', after = 'cmp_luasnip'},
    --         {'cmp-nvim-lsp', after = 'cmp-buffer'},
    --         {'cmp-path', after = 'cmp-nvim-lsp'},
    --         {'cmp-cmdline', after = 'cmp-path' },
    --         {'lspkind-nvim'},
    --     },
    --     config = require('plugins.config.nvim_cmp').init
    -- },
    nvim_autopairs = {
        'nvim-autopairs',
        opt = true,
        after = 'nvim-cmp',
        config = require('plugins.config.nvim_autopairs').init
    },
    treesitter = {
        'nvim-treesitter',
        run = ':TSUpdate',
        opt = true,
        event = 'BufRead',
        requires = {
            {'nvim-treesitter-textobjects', opt = true},
            {'nvim-treesitter-context', opt = true},
            {'nvim-ts-rainbow', opt = true},
            {'nvim-ts-context-commentstring', opt = true},
        },
        config = require('plugins.config.treesitter').init
    },
    nvim_comment = {
        'nvim-comment',
        opt = true,
        cmd = {'CommentToggle'},
        requires = {
            {'nvim-ts-context-commentstring', opt = true},
        },
        config = require('plugins.config.nvim_comment').init
    },
    -- auto_session = {
      --   'auto-session',
        -- config = require('plugins.config.auto_session').init
    -- },
}

return plugins
