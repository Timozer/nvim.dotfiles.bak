local M = {
    groups = {
        TTreeRootFolder   = { fg = "Purple" },

        TTreeFolderClosed = { fg = "#519aba" },
        TTreeFolderOpened = { fg = "#519aba" },
        TTreeOpenedFile   = { gui = "bold", fg = "Green" },

        TTreeGitIgnored = { fg = "#7e603e" },
        TTreeGitUntracked = { fg = "#73c991" },
        TTreeGitModified = { fg = "#ca3030" },
        TTreeGitStaged = { fg = "#7b9969" },
        TTreeGitAdded = { fg = "#699373" },
        TTreeGitRenamed = { fg = "#cbcb3c" },
    }
}

function M.setup()
    for k, v in pairs(M.groups) do
        local gui = v.gui and " gui=" .. v.gui or ""
        local fg = v.fg and " guifg=" .. v.fg or ""
        local bg = v.bg and " guibg=" .. v.bg or ""
        vim.api.nvim_command("hi def " .. k .. gui .. fg .. bg)
    end
end

return M
