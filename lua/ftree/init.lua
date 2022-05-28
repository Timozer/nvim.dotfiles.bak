
local M = {}

-- local function setup_autocommands(opts)
--   vim.cmd "au User FugitiveChanged,NeogitStatusRefreshed lua require'ftree.actions.reloaders'.reload_git()"

--   if opts.update_cwd then
--     vim.cmd "au DirChanged * lua require'ftree'.change_dir(vim.loop.cwd())"
--   end
--   if opts.update_focused_file.enable then
--     vim.cmd "au BufEnter * lua require'ftree'.find_file(false)"
--   end

-- end

function M.setup(opts)
    opts = opts or {}

    require("ftree.icons").setup(opts.icons)
    require("ftree.log").setup(opts.log or { level = "debug", path = "ftree.log" })
    require("ftree.actions").setup(opts.actions)

    local tree = require("ftree.node").New()
    local view = require("ftree.view")
    local renderer = require("ftree.renderer")
    renderer.setup({ view = view, tree = tree, keymaps = opts.keymaps })

    vim.cmd "silent! autocmd! FileExplorer *"
    vim.cmd "autocmd VimEnter * ++once silent! autocmd! FileExplorer *"
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    vim.cmd [[
        command! FTreeToggle lua require('ftree.renderer').Toggle()
        command! FTreeFocus lua require('ftree.renderer').Focus()
    ]]

    vim.cmd "augroup FTree"
    vim.cmd "autocmd!"

    vim.cmd "au ColorScheme * lua require('ftree').ResetHighlights()"
    vim.cmd "au WinEnter FTree* lua require('ftree').CloseWhenOnlySelf()"
    vim.cmd "au WinEnter FTree* lua require('ftree.view').SavePrevWinid()"

    vim.cmd "augroup end"
end

function M.CloseWhenOnlySelf()
    local wins = vim.api.nvim_list_wins()
    if #wins == 1 and wins[1] == require("ftree.renderer").view:GetWinid() then
        vim.cmd ":q"
    end
end

local function SetHighlightGroups(groups)
    for k, v in pairs(groups) do
        local gui = v.gui and " gui=" .. v.gui or ""
        local fg = v.fg and " guifg=" .. v.fg or ""
        local bg = v.bg and " guibg=" .. v.bg or ""
        vim.api.nvim_command("hi def " .. k .. gui .. fg .. bg)
    end
end

local function SetHighlightLinks(links)
    for k, v in pairs(links) do
        local gui = v.gui and " gui=" .. v.gui or ""
        local fg = v.fg and " guifg=" .. v.fg or ""
        local bg = v.bg and " guibg=" .. v.bg or ""
        vim.api.nvim_command("hi def " .. k .. gui .. fg .. bg)
    end
end

local highlights = {
    groups = {
        FTreeRootFolder   = { fg = "Purple" },

        FTreeFolderClosed = { fg = "#519aba" },
        FTreeFolderOpened = { fg = "#519aba" },
        FTreeOpenedFile   = { gui = "bold", fg = "Green" },

        FTreeGitIgnored = { fg = "#7e603e" },
        FTreeGitUntracked = { fg = "#73c991" },
        FTreeGitModified = { fg = "#ca3030" },
        FTreeGitStaged = { fg = "#7b9969" },
        FTreeGitAdded = { fg = "#699373" },
        FTreeGitRenamed = { fg = "#cbcb3c" },
        SlineFilename = { fg = "#ffff00", bg = '#282c34', gui = 'bold'},
        SlineFileStatus = { fg = "#ff0000", bg = '#282c34' },
        SlineFiletype = { fg = "#00ffff", bg = '#282c34' },
        SlineFileformat = { fg = "#00ffff", bg = '#282c34' },
        SlineEncoding = { fg = "#00ffff", bg = '#282c34' },
        SlineLocation = { fg = "#00ffff", bg = '#282c34' },
        SlineDefault = { fg = '#c5cdd9', bg = '#282c34' },
    },
    links = {
    }
}

function M.ResetHighlights()
    SetHighlightGroups(highlights.groups)
    require("ftree.icons").setup()
end

return M
