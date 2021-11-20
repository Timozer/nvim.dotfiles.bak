local config = {}

function config.init()
    vim.cmd [[set background=dark]]
    vim.g.edge_style = "aura"
    vim.g.edge_enable_italic = 1
    vim.g.edge_disable_italic_comment = 1
    vim.g.edge_show_eob = 1
    vim.g.edge_better_performance = 1

    vim.cmd [[ colorscheme edge ]]
end

return config
