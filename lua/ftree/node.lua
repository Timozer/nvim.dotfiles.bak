local utils = require "ftree.utils"

local log = require("ftree.log")

local M = {
    is_windows = vim.fn.has "win32" == 1,
}
M.__index = M

function M:GetNode(abs_path)
    for _, node in ipairs(self.nodes) do
        if node.abs_path == abs_path then
            return node
        end
    end
    return nil
end

function M:AddNode(opts)
    opts.parent = self
    table.insert(self.nodes, M.New(opts, false))
end

function M:AddFolder(opts)
    opts.ftype = "folder"
    opts.nodes = {}
    opts.status = "closed"
    self:AddNode(opts)
end

function M:AddFile(opts)
    opts.ftype = "file"
    opts.ext = string.match(opts.name, ".?[^.]+%.(.*)") or ""
    self:AddNode(opts)
end

function M:AddLink(opts)
    opts.ftype = "link"
    opts.link_to = vim.loop.fs_realpath(opts.abs_path) 
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
    self:AddNode(opts)
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

function M.New(opts, load)
    local node = setmetatable(opts or {abs_path = vim.loop.fs_realpath(vim.loop.cwd()), ftype = "folder", nodes = {}, status="opened"}, M)
    node.name = node.name or vim.fn.fnamemodify(node.abs_path, ":t")
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

    -- 1. add node
    while true do
        local name, t = vim.loop.fs_scandir_next(handle)
        if not name then
            break
        end

        local path = utils.path_join({self.abs_path, name})
        if self:GetNode(path) == nil then
            t = t or (vim.loop.fs_stat(path) or {}).type
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

    -- 2. check node
    local i = 1
    while i <= #self.nodes do
        if not utils.file_exists(self.nodes[i].abs_path) then
            table.remove(self.nodes, i)
        else
            if (self.nodes[i].ftype == "folder" or (self.nodes[i].ftype == "link" and self.nodes[i].link_type == "folder")) and self.nodes[i].status == "opened" then
                self.nodes[i]:Load()
            end
            i = i + 1
        end
    end

    -- 3. sort node
    table.sort(self.nodes, M.NodeCompare)
end

function M.NodeCompare(lh, rh)
    if lh.ftype ~= rh.ftype then
        if lh.ftype == "folder" then
            return true
        elseif rh.ftype == "folder" then
            return false
        elseif lh.ftype == "link" and lh.link_type == "folder" then
            return true
        elseif rh.ftype == "link" and rh.link_type == "folder" then
            return fasle
        elseif lh.ftype == "file" then
            return true
        elseif rh.ftype == "file" then
            return false
        else
            return true
        end
    end

    return lh.name < rh.name
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
