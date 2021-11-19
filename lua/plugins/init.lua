local plugins = {
    packer = { 'wbthomason/packer.nvim' },
    telescope = {
        'nvim-telescope/telescope.nvim',
        requires = { {'nvim-lua/plenary.nvim'} }
    },
    telescope_fzf_native = {
        'nvim-telescope/telescope-fzf-native.nvim',
        run = 'make'
    },
    gitsigns = {
        'lewis6991/gitsigns.nvim',
        requires = {'nvim-lua/plenary.nvim'},
    },
    edge = {
        'sainnhe/edge'
    },
    nvim_tree = {
        'kyazdani42/nvim-tree.lua',
        requires = 'kyazdani42/nvim-web-devicons',
        config = function() require'nvim-tree'.setup {} end
    },
    vim_easy_align = {
        'junegunn/vim-easy-align',
    },
    nvim_comment = {
        'terrortylor/nvim-comment'
    },
    nvim_cmp = {
        'hrsh7th/nvim-cmp'
    }
}

return plugins
