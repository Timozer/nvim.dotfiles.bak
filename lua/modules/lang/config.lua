local config = {}
local exec = vim.api.nvim_command

-- function config.lang_go() vim.g.go_doc_keywordprg_enabled = false end

function config.lang_org()
    require('orgmode').setup({
        org_agenda_files = {'~/Sync/org/*'},
        org_default_notes_file = '~/Sync/org/refile.org'
    })
end

return config
