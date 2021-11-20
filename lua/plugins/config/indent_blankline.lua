local config = {}

function config.init()
    -- vim.cmd [[highlight IndentTwo guifg=#D08770 guibg=NONE gui=nocombine]]
    -- vim.cmd [[highlight IndentThree guifg=#EBCB8B guibg=NONE gui=nocombine]]
    -- vim.cmd [[highlight IndentFour guifg=#A3BE8C guibg=NONE gui=nocombine]]
    -- vim.cmd [[highlight IndentFive guifg=#5E81AC guibg=NONE gui=nocombine]]
    -- vim.cmd [[highlight IndentSix guifg=#88C0D0 guibg=NONE gui=nocombine]]
    -- vim.cmd [[highlight IndentSeven guifg=#B48EAD guibg=NONE gui=nocombine]]
    -- vim.g.indent_blankline_char_highlight_list = {
    --     "IndentTwo", "IndentThree", "IndentFour", "IndentFive", "IndentSix",
    --     "IndentSeven"
    -- }
    require("indent_blankline").setup {
        char = "│",
        show_first_indent_level = true,
        filetype_exclude = {
            "startify", "dashboard", "dotooagenda", "log", "fugitive",
            "gitcommit", "packer", "vimwiki", "markdown", "json", "txt",
            "vista", "help", "todoist", "NvimTree", "peekaboo", "git",
            "TelescopePrompt", "undotree", "flutterToolsOutline", "" -- for all buffers without a file type
        },
        buftype_exclude = {"terminal", "nofile"},
        show_trailing_blankline_indent = false,
        show_current_context = true,
        context_patterns = {
            "class", "function", "method", "block", "list_literal", "selector",
            "^if", "^table", "if_statement", "while", "for", "type", "var",
            "import"
        }
    }
    -- because lazy load indent-blankline so need readd this autocmd
    vim.cmd('autocmd CursorMoved * IndentBlanklineRefresh')
end

return config
