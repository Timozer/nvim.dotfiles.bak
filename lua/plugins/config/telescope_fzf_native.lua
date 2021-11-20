local config = {}

function config.init()
    print('init telescope fzf')
    require('telescope').load_extension('fzf')
end

return config
