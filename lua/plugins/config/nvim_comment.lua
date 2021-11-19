require('nvim_comment').setup({
    -- Linters prefer comment and line to have a space in between markers
    marker_padding = true,
    -- should comment out empty or whitespace only lines
    comment_empty = false,
    -- Should key mappings be created
    create_mappings = true,
    -- Normal mode mapping left hand side
    line_mapping = "<C-_>",
    -- Visual/Operator mapping left hand side
    operator_mapping = "<C-_>",
    -- Hook function to call before commenting takes place
    hook = nil,
    -- hook = function()
        -- require('ts_context_commentstring.internal').update_commentstring()
    -- end
})
