local Runner = require "ftree.git.runner"

local M = {
    config = nil,
    projects = {},
}

local untracked = {}

function M.rootpath(cwd)
    local cmd = "git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel"
    local toplevel = vim.fn.system(cmd)

    if not toplevel or #toplevel == 0 or toplevel:match "fatal" then
        return nil
    end

    -- git always returns path with forward slashes
    if vim.fn.has "win32" == 1 then
        toplevel = toplevel:gsub("/", "\\")
    end

    -- remove newline
    return toplevel:sub(0, -2)
end

function M.should_show_untracked(cwd)
    if untracked[cwd] ~= nil then
        return untracked[cwd]
    end

    local cmd = "git -C " .. cwd .. " config --type=bool status.showUntrackedFiles"
    local has_untracked = vim.fn.system(cmd)
    untracked[cwd] = vim.trim(has_untracked) ~= "false"
    return untracked[cwd]
end

function M.file_status_to_dir_status(status, cwd)
    local dirs = {}
    for p, s in pairs(status) do
        if s ~= "!!" then
            local modified = vim.fn.fnamemodify(p, ":h")
            dirs[modified] = s
        end
    end

    for dirname, s in pairs(dirs) do
        local modified = dirname
        while modified ~= cwd and modified ~= "/" do
            modified = vim.fn.fnamemodify(modified, ":h")
            dirs[modified] = s
        end
    end

    return dirs
end


function M.reload()
    for project_root in pairs(M.projects) do
        M.projects[project_root] = {}
        local git_status = Runner.run {
            project_root = project_root,
            list_untracked = M.should_show_untracked(project_root),
            list_ignored = true,
            timeout = 400,
        }
        M.projects[project_root] = {
            files = git_status,
            dirs = M.file_status_to_dir_status(git_status, project_root),
        }
    end

    return M.projects
end

function M.load_project_status(cwd)
    local project_root = M.rootpath(cwd)
    if not project_root then
        return {}
    end

    local status = M.projects[project_root]
    if status then
        return status
    end

    local git_status = Runner.run {
        project_root = project_root,
        list_untracked = M.should_show_untracked(project_root),
        list_ignored = true,
        timeout = nil,
    }
    M.projects[project_root] = {
        files = git_status,
        dirs = M.file_status_to_dir_status(git_status, project_root),
    }
    return M.projects[project_root]
end

function M.setup(opts)
end

return M
