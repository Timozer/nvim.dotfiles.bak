local plugins = {
    packer = { 'wbthomason/packer.nvim' },
    telescope = {
        'nvim-telescope/telescope.nvim',
        requires = { {'nvim-lua/plenary.nvim'} },
        config = require('plugins.config.telescope').init
    },
    telescope_fzf_native = {
        'nvim-telescope/telescope-fzf-native.nvim',
        run = 'make',
        config = require('plugins.config.telescope_fzf_native').init
    },
    gitsigns = {
        'lewis6991/gitsigns.nvim',
        requires = {'nvim-lua/plenary.nvim'},
        config = require('plugins.config.gitsigns').init
    },
    edge = {
        'sainnhe/edge',
        config = require('plugins.config.edge').init,
    },
    nvim_tree = {
        'kyazdani42/nvim-tree.lua',
        requires = 'kyazdani42/nvim-web-devicons',
        config = require('plugins.config.nvim_tree').init
    },
    vim_easy_align = {
        'junegunn/vim-easy-align',
    },
    nvim_comment = {
        'terrortylor/nvim-comment',
        config = require('plugins.config.nvim_comment').init
    },
    nvim_lspconfig = {
        "neovim/nvim-lspconfig",
        config = function() print('inti lsp') end
    },
    nvim_lsp_installer = {
        'williamboman/nvim-lsp-installer',
        after = {"nvim-lspconfig"},
        config = require('plugins.config.nvim_lsp_installer').init
    },
    nvim_lightbulb = {
        'kosayoda/nvim-lightbulb',
        after = 'nvim-lspconfig',
        config = require('plugins.config.nvim_lightbulb').init
    },
    lspsaga = {
        'tami5/lspsaga.nvim',
        after = 'nvim-lspconfig',
        config = require('plugins.config.lspsaga').init
    },
    symbols_outline = {
        'simrat39/symbols-outline.nvim',
        config = require('plugins.config.symbols_outline').init
    },
    trouble = {
        'folke/trouble.nvim',
        config = require('plugins.config.trouble').init
    },
    luasnip = {
        'L3MON4D3/LuaSnip',
        after = 'nvim-cmp',
        requires = 'rafamadriz/friendly-snippets',
        config = function()
            require('luasnip').config.set_config {
                history = true,
                updateevents = "TextChanged,TextChangedI"
            }
            require("luasnip/loaders/from_vscode").load()
        end
    },
    nvim_cmp = {
        'hrsh7th/nvim-cmp',
        requires = {
            {'onsails/lspkind-nvim'},
            {'saadparwaiz1/cmp_luasnip', after = 'LuaSnip'},
            {'hrsh7th/cmp-buffer', after = 'cmp_luasnip'},
            {'hrsh7th/cmp-path'},
            {'hrsh7th/cmp-cmdline'},
            {'hrsh7th/cmp-nvim-lsp'},
        },
        config = require('plugins.config.nvim_cmp').init
    },
    nvim_autopairs = {
        'windwp/nvim-autopairs',
        after = 'nvim-cmp',
        config = require('plugins.config.nvim_autopairs').init
    },
    filetype = {
        'nathom/filetype.nvim'
    },
    startuptime = {
        'dstein64/vim-startuptime'
    },
    treesitter = {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = require('plugins.config.treesitter').init
    },
    treesitter_textobjects = {
        'nvim-treesitter/nvim-treesitter-textobjects',
        after = 'nvim-treesitter',
    },
    treesitter_context = {
        'romgrk/nvim-treesitter-context',
        after = 'nvim-treesitter',
    },
    ts_rainbow = {
        'p00f/nvim-ts-rainbow',
        after = 'nvim-treesitter',
    },
    ts_context_commentstring = {
        'JoosepAlviste/nvim-ts-context-commentstring',
        after = 'nvim-treesitter',
    },
    matchup = {
        'andymass/vim-matchup',
        after = 'nvim-treesitter',
        config = function()
            vim.cmd [[let g:matchup_matchparen_offscreen = {'method': 'popup'}]]
        end
    },
    nvim_gps = {
        'SmiteshP/nvim-gps',
        after = 'nvim-treesitter',
        config = require('plugins.config.nvim_gps').init
    },
    lsp_process = {
        'arkav/lualine-lsp-progress',
        after = 'nvim-gps',
    },
    lualine = {
        'nvim-lualine/lualine.nvim',
        requires = {'kyazdani42/nvim-web-devicons', opt = true},
        after = 'lualine-lsp-progress',
        config = require('plugins.config.lualine').init
    },
    auto_session = {
        'rmagatti/auto-session',
        config = require('plugins.config.auto_session').init
    },
    indent_blankline = {
        'lukas-reineke/indent-blankline.nvim',
        config = require('plugins.config.indent_blankline').init
    }
}

return plugins
