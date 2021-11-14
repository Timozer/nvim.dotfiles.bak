local editor = {}
local conf = require('modules.editor.config')

editor['junegunn/vim-easy-align'] = {opt = true, cmd = 'EasyAlign'}
editor['itchyny/vim-cursorword'] = {
    opt = true,
    event = {'BufReadPre', 'BufNewFile'},
    config = conf.vim_cursorwod
}
editor['terrortylor/nvim-comment'] = {
    opt = false,
    config = function()
        require('nvim_comment').setup({
            hook = function()
                require("ts_context_commentstring.internal").update_commentstring()
            end
        })
    end
}
editor['simrat39/symbols-outline.nvim'] = {
    opt = true,
    cmd = {'SymbolsOutline', 'SymbolsOulineOpen'},
    config = conf.symbols_outline
}
editor['nvim-treesitter/nvim-treesitter'] = {
    opt = true,
    run = ':TSUpdate',
    event = 'BufRead',
    config = conf.nvim_treesitter
}
editor['nvim-treesitter/nvim-treesitter-textobjects'] = {
    opt = true,
    after = 'nvim-treesitter'
}
editor['romgrk/nvim-treesitter-context'] = {
    opt = true,
    after = 'nvim-treesitter'
}
editor['p00f/nvim-ts-rainbow'] = {
    opt = true,
    after = 'nvim-treesitter',
    event = 'BufRead'
}
editor['SmiteshP/nvim-gps'] = {
    opt = true,
    after = 'nvim-treesitter',
    config = conf.nvim_gps
}
editor['romainl/vim-cool'] = {
    opt = true,
    event = {'CursorMoved', 'InsertEnter'}
}
editor['akinsho/toggleterm.nvim'] = {
    opt = true,
    event = 'BufRead',
    config = conf.toggleterm
}
editor['numtostr/FTerm.nvim'] = {opt = true, event = 'BufRead'}
editor['norcalli/nvim-colorizer.lua'] = {
    opt = true,
    event = 'BufRead',
    config = conf.nvim_colorizer
}
editor['rmagatti/auto-session'] = {
    opt = true,
    cmd = {'SaveSession', 'RestoreSession', 'DeleteSession'},
    config = conf.auto_session
}

return editor
