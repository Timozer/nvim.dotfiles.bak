    -- display
    -- gitsigns = {
        -- 'gitsigns.nvim',
        -- opt = true,
        -- event = {'BufRead', 'BufNewFile' },
        -- requires = {'plenary.nvim', opt=true,},
        -- config = require('plugins.config.gitsigns').init
    -- },
    -- indent_blankline = {
        -- 'indent-blankline.nvim',
        -- opt = true,
        -- event = 'BufRead',
        -- config = require('plugins.config.indent_blankline').init
    -- },
    -- nui_nvim = {
        -- 'nui.nvim'
    -- },
    -- editor
    -- float windows
    -- telescope = {
        -- 'telescope.nvim',
        -- opt = true,
        -- cmd = 'Telescope',
        -- requires = { {'plenary.nvim'} },
        -- config = require('plugins.config.telescope').init
    -- },
    -- telescope_fzf_native = {
        -- 'telescope-fzf-native.nvim',
        -- opt = true,
        -- after = "telescope.nvim",
        -- run = 'make',
        -- config = require('plugins.config.telescope_fzf_native').init
    -- },
    -- symbols explorer
    -- symbols_outline = {
        -- 'symbols-outline.nvim',
        -- opt = true,
        -- cmd = {'SymbolsOutline', 'SymbolsOutlineOpen' },
        -- config = require('plugins.config.symbols_outline').init
    -- },
    -- lsp
    -- nvim_lightbulb = {
        -- 'nvim-lightbulb',
        -- opt = true,
        -- after = 'nvim-lspconfig',
        -- config = require('plugins.config.nvim_lightbulb').init
    -- },
    --lspsaga = {
        --'lspsaga.nvim',
        --after = 'nvim-lspconfig',
        --config = require('plugins.config.lspsaga').init
    --},
    -- luasnip = {
        -- 'LuaSnip',
        -- opt = true,
        -- after = 'nvim-cmp',
        -- requires = { 'friendly-snippets' },
        -- config = function()
            -- if not packer_plugins["LuaSnip"].loaded then
                -- vim.cmd [[packadd LuaSnip]]
            -- end
            -- if not packer_plugins["friendly-snippets"].loaded then
                -- vim.cmd [[packadd friendly-snippets]]
            -- end
            -- require('luasnip').config.set_config {
                -- history = true,
                -- updateevents = "TextChanged,TextChangedI"
            -- }
            -- require("luasnip/loaders/from_vscode").load()
        -- end
    -- },
    -- lspkind = {
        -- 'lspkind-nvim'
    -- },
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
    -- nvim_autopairs = {
        -- 'nvim-autopairs',
        -- opt = true,
        -- after = 'nvim-cmp',
        -- config = require('plugins.config.nvim_autopairs').init
    -- },
    -- treesitter = {
        -- 'nvim-treesitter',
        -- run = ':TSUpdate',
        -- opt = true,
        -- event = 'BufRead',
        -- requires = {
            -- {'nvim-treesitter-textobjects', opt = true},
            -- {'nvim-treesitter-context', opt = true},
            -- {'nvim-ts-rainbow', opt = true},
            -- {'nvim-ts-context-commentstring', opt = true},
        -- },
        -- config = require('plugins.config.treesitter').init
    -- },
    -- nvim_comment = {
        -- 'nvim-comment',
        -- opt = true,
        -- cmd = {'CommentToggle'},
        -- requires = {
            -- {'nvim-ts-context-commentstring', opt = true},
        -- },
        -- config = require('plugins.config.nvim_comment').init
    -- },
    -- auto_session = {
      --   'auto-session',
        -- config = require('plugins.config.auto_session').init
    -- },


local M = {}

function M.SetUp(opts)
    opts = opts or {}
    vim.g.gpm_config = {
        log = {
            dir = vim.fn.stdpath("config") .. "/.cache/gpm/logs/",
            level = "debug", -- debug | info
        },
        plugin = {
            install_path = vim.fn.stdpath("config") .. "/pack/",
            compile_path = vim.fn.stdpath("config") .. "/plugin/gpm_compiled.lua",
            plugins = {
                {
                    type = "git",
                    path = "https://github.com/nathom/filetype.nvim",
                    setup = require("plugins.setup.filetype").SetUp
                },
                {
                    type = "git",
                    path = "https://github.com/sainnhe/edge",
                    setup = require("plugins.setup.edge").SetUp
                },
                {
                    type = "git", -- git | local | http
                    path = "https://github.com/neovim/nvim-lspconfig",
                    setup = require("plugins.setup.lspconfig").SetUp
                },
                {
                    type = "git",
                    path = "https://github.com/junegunn/vim-easy-align",
                    opt = false,
                    setup = require("plugins.setup.vim_easy_align").SetUp,
                    event = {
                        { name = 'BurReadPre', pattern = "*" }
                    }
                }
            }
        }
    }
end

return M
