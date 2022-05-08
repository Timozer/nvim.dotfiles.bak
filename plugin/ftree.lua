
if vim.g.ftree_loaded == 1 then
    return
end

if vim.api.nvim_call_function('has', {'nvim-0.7'}) ~= 1 then
    vim.fn.nvim_out_write("ftree requires at least nvim-0.7")
    return
end

vim.g.ftree_loaded = 1

local renderer = require("ftree.renderer")
local actions = require("ftree.actions")

require("ftree").setup({
    icons      = {},
    highlights = {},
    log        = { level = "debug", path = "ftree.log" },
    actions    = {},
    keymaps    = {
        ["tree"] = {
            {
                mode = 'n',
                lhs = '<CR>',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.CR),
                    desc = 'CR Action' 
                }
            },
            {
                mode = 'n',
                lhs = '<C-]>',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.VSplitFile),
                    desc = 'VSplit File' 
                }
            },
            {
                mode = 'n',
                lhs = '<C-s>',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.SplitFile),
                    desc = 'Split File' 
                }
            },
            {
                mode = 'n',
                lhs = 'i',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.DirIn),
                    desc = 'Dir In',
                    noremap = true,
                    silent = true,
                    nowait = true,
                }
            },
            {
                mode = 'n',
                lhs = 'o',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.DirOut),
                    desc = 'Dir Out' 
                }
            },
            {
                mode = 'n',
                lhs = 'a',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.NewFile),
                    desc = 'New Dir or File' 
                }
            },
            {
                mode = 'n',
                lhs = 'r',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.RenameFile),
                    desc = 'Rename File' 
                }
            },
            {
                mode = 'n',
                lhs = 'R',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.Refresh),
                    desc = 'Refresh' 
                }
            },
            {
                mode = 'n',
                lhs = '<Del>',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.RemoveFile),
                    desc = 'Remove File' 
                }
            },
            {
                mode = 'n',
                lhs = 'y',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.CopyFileName),
                    desc = 'Copy Filename To Clipboard' 
                }
            },
            {
                mode = 'n',
                lhs = 'Y',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.CopyAbsPath),
                    desc = 'Copy AbsPath To Clipboard' 
                }
            },
            {
                mode = 'n',
                lhs = '<BS>',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.MoveToParent(true)),
                    desc = 'Move To Parent Node' 
                }
            },
            {
                mode = 'n',
                lhs = '[[',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.MoveToParent(false)),
                    desc = 'Move To Parent Node' 
                }
            },
            {
                mode = 'n',
                lhs = ']]',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.MoveToLastChild),
                    desc = 'Move To Last Child' 
                }
            },
            {
                mode = 'n',
                lhs = 'J',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.MoveToNextSibling),
                    desc = 'Move To Next Sibling' 
                }
            },
            {
                mode = 'n',
                lhs = 'K',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.MoveToPrevSibling),
                    desc = 'Move To Prev Sibling' 
                }
            },
            {
                mode = 'n',
                lhs = '<C-h>',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.ToggleDotFiles),
                    desc = 'Toggle Dot Files' 
                }
            },
            {
                mode = 'n',
                lhs = '<C-g>',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.ToggleGitIgnoredFiles),
                    desc = 'Toggle Git Ignored Files' 
                }
            },
            {
                mode = 'n',
                lhs = '<C-k>',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.ShowFileInfo),
                    desc = 'Show File Info' 
                }
            },
            {
                mode = 'n',
                lhs = 'm',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.ToggleMark),
                    desc = 'Show File Info' 
                }
            },
            {
                mode = 'n',
                lhs = '<ESC>',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.ClearMarks),
                    desc = 'Clear Marks' 
                }
            },
            {
                mode = 'n',
                lhs = '<C-c>',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.Copy),
                    desc = 'Copy File' 
                }
            },
            {
                mode = 'n',
                lhs = '<C-x>',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.Cut),
                    desc = 'Cut File' 
                }
            },
            {
                mode = 'n',
                lhs = 'p',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.Paste),
                    desc = 'Paste File' 
                }
            },
            {
                mode = 'n',
                lhs = '<C-a>',
                rhs = '',
                opts = { 
                    callback = renderer.DoAction(actions.ShowActionInfo),
                    desc = 'Show Action Info' 
                }
            }
        },
    },
})

vim.api.nvim_set_keymap('n', "<leader>fl", ":FTreeToggle<cr>", {noremap = true})
vim.api.nvim_set_keymap('n', "<leader>fc", ":FTreeFocus<cr>", {noremap = true})
