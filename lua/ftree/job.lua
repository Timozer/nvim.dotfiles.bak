local uv = vim.loop
local log = require "ftree.log"

local M = {}
M.__index = M

function M.New(opts)
    local opts = opts or {args = {}}
    opts.timeout = opts.timeout or 400
    opts.cwd = opts.cwd or "."

    opts.stdout = ""
    opts.stderr = ""
    opts.stdout_pipe = uv.new_pipe()
    opts.stderr_pipe = uv.new_pipe()
    opts.stdio = {nil, opts.stdout_pipe, opts.stderr_pipe}

    opts.timer = uv.new_timer()

    opts.handle = nil
    opts.pid = nil

    local job = setmetatable(opts, M)
    return job
end

function M:_Run()
    if self.path == nil then
        return
    end

    self.handle, self.pid = uv.spawn(
        self.path, self, 
        vim.schedule_wrap(function(code, signal)
            self:OnFinish(code, signal)
        end)
    )

    self.timer:start(
        self.timeout, 0,
        vim.schedule_wrap(function()
            self:OnFinish(-1)
        end)
    )

    uv.read_start(self.stdout_pipe, vim.schedule_wrap(function(err, data)
        if err then
            log.error("ReadStdout Error: %s\n", vim.inspect(err))
            return
        end
        if data then
            self.stdout = self.stdout .. data
        end
    end))

    uv.read_start(self.stderr_pipe, vim.schedule_wrap(function(_, data)
        log.debug("Stderr: %s\n", data)
        if data then
            self.stderr = self.stderr .. data
        end
    end))
end

function M:Wait()
    log.debug("Start to wait job\n")
    while not vim.wait(30, function() return self.status ~= nil end) do
    end
end

function M:Run()
    self:_Run()
    self:Wait()
end

function M:OnFinish(code, signal)
    self.status = code or 0
    self.signal = signal or 0

    if self.timer:is_closing() or 
        self.stdout_pipe:is_closing() or self.stderr_pipe:is_closing() or 
        (self.handle and self.handle:is_closing()) then
        return
    end

    self.timer:stop()
    self.timer:close()

    self.stdout_pipe:read_stop()
    self.stderr_pipe:read_stop()
    self.stdout_pipe:close()
    self.stderr_pipe:close()

    if self.handle then
        self.handle:close()
    end

    pcall(uv.kill, self.pid)
end

return M

