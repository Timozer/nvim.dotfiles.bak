local M = {
    config = {
        sections = {
            ['lside'] = {
                "LeftSide"
            },
            ['center'] = {
                "Center"
            },
            ['rside'] = {
                "RightSide"
            }
        },
        disabled_filetypes = {
            "FTree"
        }
    }
}

function M.Redraw()
end

function M.Filename()
    return "%f"
end

function M.GitBranch()
    return "master"
end

function M.GitDiff()
    return "+3,-1"
end

function M.StatusLine()
    local retval
    local ftype = vim.bo.filetype

    for _, ft in pairs(M.config.disabled_filetypes) do
        if ft == ftype then
            return ''
        end
    end

    local status = {
        "%-(%#IncSearch#%{%v:lua.require('sline').Filename()%}%m%r|%{%v:lua.require('sline').GitBranch()%}|%)",
        "%=%(Center%)",
        "%=%(%yBuffer:%n Byte:%o Percentage:%p%% %l/%L:%c%)",
    }

    local ret = table.concat(status)
    return ret
end

function M.SetUp(opts)
    opts = opts or {}

    vim.cmd([[
        augroup SLINE
        autocmd!
        autocmd VimResized * redrawstatus
        augroup END
    ]])

    vim.go.statusline = "%{%v:lua.require('sline').StatusLine()%}"
end
%#lualine_a_normal# [No Name] %#lualine_transitional_lualine_a_normal_to_lualine_b_normal#%#lualine_b_normal#  master %#lualine_transitional_lualine_b_normal_to_lualine_c_normal#%<%#lualine_c_normal#%=%#lualine_transitional_lualine_b_normal_to_lualine_c_normal#%#lualine_b_normal# utf-8 |%#lualine_b_normal#  %#lualine_transitional_lualine_a_normal_to_lualine_b_normal#%#lualine_a_normal# %3p%% |%#lualine_a_normal# %3l:%-2v 

%<%#lualine_c_inactive# [No Name] %#lualine_c_inactive#%=%#lualine_c_inactive# %3l:%-2v 
return M
