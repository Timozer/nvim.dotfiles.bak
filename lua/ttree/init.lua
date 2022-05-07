
local M = {}

-- local function setup_autocommands(opts)
--   vim.cmd "augroup TTree"
--   vim.cmd "autocmd!"

--   -- reset highlights when colorscheme is changed
--   vim.cmd "au ColorScheme * lua require'ftree'.reset_highlight()"
--   if opts.auto_reload_on_write then
--     vim.cmd "au BufWritePost * lua require'ftree.actions.reloaders'.reload_explorer()"
--   end
--   vim.cmd "au User FugitiveChanged,NeogitStatusRefreshed lua require'ftree.actions.reloaders'.reload_git()"

--   if opts.open_on_tab then
--     vim.cmd "au TabEnter * lua require'ftree'.tab_change()"
--   end
--   if opts.hijack_cursor then
--     vim.cmd "au CursorMoved FTree_* lua require'ftree'.place_cursor_on_node()"
--   end
--   if opts.update_cwd then
--     vim.cmd "au DirChanged * lua require'ftree'.change_dir(vim.loop.cwd())"
--   end
--   if opts.update_focused_file.enable then
--     vim.cmd "au BufEnter * lua require'ftree'.find_file(false)"
--   end

--   if not opts.actions.open_file.quit_on_open then
--     vim.cmd "au BufWipeout FTree_* lua require'ftree.view'._prevent_buffer_override()"
--   else
--     vim.cmd "au BufWipeout FTree_* lua require'ftree.view'.abandon_current_window()"
--   end

--   if opts.hijack_directories.enable then
--     vim.cmd "au BufEnter,BufNewFile * lua require'ftree'.open_on_directory()"
--   end

--   vim.cmd "augroup end"
-- end

local function setup_vim_commands()
  vim.cmd [[
    command! TTreeToggle lua require('ttree.renderer').Toggle()
    command! TTreeFocus lua require('ttree.renderer').Focus()
  ]]
end

function M.setup(opts)
    opts = opts or {}

    require("ttree.icons").setup(opts.icons)
    require("ttree.highlight").setup(opts.highlights)
    require("ttree.log").setup(opts.log or { level = "debug", path = "ttree.log" })
    require("ttree.actions").setup(opts.actions)

    vim.cmd "silent! autocmd! FileExplorer *"
    vim.cmd "autocmd VimEnter * ++once silent! autocmd! FileExplorer *"
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    setup_vim_commands()

    local tree = require("ttree.node").New()
    local view = require("ttree.view")
    local renderer = require("ttree.renderer")
    local actions = require('ttree.actions')

    renderer.setup({
        view = view,
        tree = tree,
        keymaps = {
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
                }
            },
            ["help"] = {
            }
        }
    })
end

return M
