local M = {
    config = {
        path = "log.log",
        level = "debug",
    },
}

function M._log(level, fmt, ...)
    if not M.config.path or M.config.path == "" then
        return
    end

    local line = string.format(fmt, ...)
    local file = io.open(M.config.path, "a")
    io.output(file)
    io.write(string.format("%s [%s] %s\n", os.date("%Y-%m-%d %H:%M:%S"), level, line))
    io.close(file)
end

function M.info(fmt, ...)
    if M.config.level == "none" then
        return
    end
    M._log("INFO", fmt, ...)
end

function M.error(fmt, ...)
    if M.config.level == "none" then
        return
    end
    M._log("ERROR", fmt, ...)
end

function M.warn(fmt, ...)
    if M.config.level == "none" then
        return
    end
    M._log("WARN", fmt, ...)
end

function M.debug(fmt, ...)
    if M.config.level == "none" or M.config.level ~= "debug" then
        return
    end
    M._log("DEBUG", fmt, ...)
end

function M.setup(opts)
    M.config = opts or { level = "none" }
    if M.config.path and M.config.path ~= "" then
        M.config.path = string.format(
            "%s/%s",
            vim.fn.stdpath("cache"),
            M.config.path
        )
    end
    print("ftree.lua logging to " .. M.config.path)
end

return M
