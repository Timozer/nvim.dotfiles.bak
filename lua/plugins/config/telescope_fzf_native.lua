local config = {}

function config.init()
    require('telescope').load_extension('fzf')
end

return config
