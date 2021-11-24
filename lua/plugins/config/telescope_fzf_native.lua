local config = {}

function config.init()
    if packer_plugins["telescope.nvim"] and packer_plugins["telescope.nvim"].loaded then
        vim.cmd [[ packadd telescope.nvim ]]
    end
    require('telescope').load_extension('fzf')
end

return config
