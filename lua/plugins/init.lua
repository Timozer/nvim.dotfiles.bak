local plugins = {
    packer = { 'packer.nvim' },
    telescope = {
        'telescope.nvim',
        requires = { {'plenary.nvim'} },
        config = require('plugins.config.telescope').init
    },
    telescope_fzf_native = {
        'telescope-fzf-native.nvim',
        run = 'make',
        config = require('plugins.config.telescope_fzf_native').init
    },
    gitsigns = {
        'gitsigns.nvim',
        requires = {'plenary.nvim'},
        config = require('plugins.config.gitsigns').init
    },
    edge = {
        'edge',
        config = require('plugins.config.edge').init,
    },
    nvim_tree = {
        'nvim-tree.lua',
        requires = 'nvim-web-devicons',
        config = require('plugins.config.nvim_tree').init
    },
    vim_easy_align = {
        'vim-easy-align',
    },
    nvim_comment = {
        'nvim-comment',
        config = require('plugins.config.nvim_comment').init
    },
    nvim_lspconfig = {
        "nvim-lspconfig",
        config = function()  end
    },
    nvim_lsp_installer = {
        'nvim-lsp-installer',
        after = {"nvim-lspconfig"},
        config = require('plugins.config.nvim_lsp_installer').init
    },
    nvim_lightbulb = {
        'nvim-lightbulb',
        after = 'nvim-lspconfig',
        config = require('plugins.config.nvim_lightbulb').init
    },
    lspsaga = {
        'lspsaga.nvim',
        after = 'nvim-lspconfig',
        config = require('plugins.config.lspsaga').init
    },
    symbols_outline = {
        'symbols-outline.nvim',
        config = require('plugins.config.symbols_outline').init
    },
    trouble = {
        'trouble.nvim',
        config = require('plugins.config.trouble').init
    },
    luasnip = {
        'LuaSnip',
        after = 'nvim-cmp',
        requires = 'friendly-snippets',
        config = function()
            require('luasnip').config.set_config {
                history = true,
                updateevents = "TextChanged,TextChangedI"
            }
            require("luasnip/loaders/from_vscode").load()
        end
    },
    nvim_cmp = {
        'nvim-cmp',
        requires = {
            {'lspkind-nvim'},
            {'cmp_luasnip', after = 'LuaSnip'},
            {'cmp-buffer', after = 'cmp_luasnip'},
            {'cmp-path'},
            {'cmp-cmdline'},
            {'cmp-nvim-lsp'},
        },
        config = require('plugins.config.nvim_cmp').init
    },
    nvim_autopairs = {
        'nvim-autopairs',
        after = 'nvim-cmp',
        config = require('plugins.config.nvim_autopairs').init
    },
    filetype = {
        'filetype.nvim'
    },
    startuptime = {
        'vim-startuptime'
    },
    treesitter = {
        'nvim-treesitter',
        run = ':TSUpdate',
        config = require('plugins.config.treesitter').init
    },
    treesitter_textobjects = {
        'nvim-treesitter-textobjects',
        after = 'nvim-treesitter',
    },
    treesitter_context = {
        'nvim-treesitter-context',
        after = 'nvim-treesitter',
    },
    ts_rainbow = {
        'nvim-ts-rainbow',
        after = 'nvim-treesitter',
    },
    ts_context_commentstring = {
        'nvim-ts-context-commentstring',
        after = 'nvim-treesitter',
    },
    matchup = {
        'vim-matchup',
        after = 'nvim-treesitter',
        config = function()
            vim.cmd [[let g:matchup_matchparen_offscreen = {'method': 'popup'}]]
        end
    },
    nvim_gps = {
        'nvim-gps',
        after = 'nvim-treesitter',
        config = require('plugins.config.nvim_gps').init
    },
    lsp_process = {
        'lualine-lsp-progress',
        after = 'nvim-gps',
    },
    lualine = {
        'lualine.nvim',
        requires = {'nvim-web-devicons', opt = true},
        after = 'lualine-lsp-progress',
        config = require('plugins.config.lualine').init
    },
    auto_session = {
        'auto-session',
        config = require('plugins.config.auto_session').init
    },
    indent_blankline = {
        'indent-blankline.nvim',
        config = require('plugins.config.indent_blankline').init
    }
}

return plugins
