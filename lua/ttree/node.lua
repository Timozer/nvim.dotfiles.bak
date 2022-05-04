local utils = require "ttree.utils"

local log = require("ttree.log")

local M = {
    is_windows = vim.fn.has "win32" == 1,
}
M.__index = M

function M:AddFolder(opts)
    opts.ftype = "folder"
    opts.group_next = nil
    opts.nodes = {}
    opts.status = "closed"
    log.debug("FTree AddFolder: %s\n", vim.inspect(opts))
    table.insert(self.nodes, M.New(opts, false))
end

function M:AddFile(opts)
    opts.ftype = "file"
    opts.ext = string.match(opts.name, ".?[^.]+%.(.*)") or ""
    log.debug("FTree AddFile: %s\n", vim.inspect(opts))
    table.insert(self.nodes, M.New(opts, false))
end

function M:AddLink(opts)
    opts.ftype = "link"
    opts.link_to = vim.loop.fs_realpath(path) 
    if opts.link_to ~= nil then
        ltype = vim.loop.fs_stat(opts.link_to).type
        if ltype == "directory" then
            opts.link_type = "folder"
            opts.nodes = {}
            opts.status = "closed"
        elseif ltype == "file" then
            opts.link_type = "file"
            opts.ext = string.match(opts.name, ".?[^.]+%.(.*)") or ""
        end
    end
end

function M:Executable()
    if M.is_windows then
        return utils.is_windows_exe(self.ext)
    end
    return self.ftype == "file" and vim.loop.fs_access(self.abs_path, "X")
end

function M:FsStat()
    return vim.loop.fs_stat(self.abs_path)
end

function M:GitStatus()
end

function M.New(opts, load)
    log.debug("FTree New Node: %s, Load: %s\n", vim.inspect(opts), load)
    local node = setmetatable(opts or {abs_path = vim.loop.fs_realpath(vim.loop.cwd()), ftype = "folder", nodes = {}, status="opened"}, M)
    if load == nil or load == true then
        node:Load()
    end
    return node
end

function M:Load()
    local handle = vim.loop.fs_scandir(self.abs_path)
    if not handle then
        return
    end

    while true do
        local name, t = vim.loop.fs_scandir_next(handle)
        if not name then
            break
        end

        local path = utils.path_join({self.abs_path, name})
        t = t or (vim.loop.fs_stat(path) or {}).type
        log.debug("FTree Next, ABS_PATH: %s, Type: %s\n", path, t)
        if t == "directory" and vim.loop.fs_access(path, "R") then
            self:AddFolder({ abs_path = path, name = name })
        elseif t == "file" then
            self:AddFile({ abs_path = path, name = name })
        elseif t == "link" then
            self:AddLink({ abs_path = path, name = name })
        else
            log.warn("Unkown type: %s\n", t)
        end
    end
end

function M:Expand()
    if self.ftype ~= "folder" and not (self.ftype == "link" and self.link_type == "folder") then
        return
    end
    self.status = "opened"
    self:Load()
end

function M:Collapse()
    if self.ftype ~= "folder" and not (self.ftype == "link" and self.link_type == "folder") then
        return
    end
    self.status = "closed"
end

return M
