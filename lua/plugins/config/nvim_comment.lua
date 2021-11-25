local config = {}

function config.init()
    if not packer_plugins["nvim-comment"].loaded then
        vim.cmd [[packadd nvim-comment]]
    end
    if not packer_plugins["nvim-ts-context-commentstring"].loaded then
        vim.cmd [[packadd nvim-ts-context-commentstring]]
    end
    require('nvim_comment').setup({
        -- Linters prefer comment and line to have a space in between markers
        marker_padding = true,
        -- should comment out empty or whitespace only lines
        comment_empty = false,
        -- Should key mappings be created
        create_mappings = true,
        -- Normal mode mapping left hand side
        line_mapping = nil,
        -- Visual/Operator mapping left hand side
        operator_mapping = nil,
        -- Hook function to call before commenting takes place
        hook = function()
            require('ts_context_commentstring.internal').update_commentstring()
        end
    })

end

return config
