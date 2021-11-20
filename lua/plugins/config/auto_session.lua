local config = {}

function config.init()
    local opts = {
        log_level = 'debug',
        auto_session_enable_last_session = false,
        auto_session_root_dir = vim.fn.stdpath('data').."/sessions/",
        auto_session_enabled = true,
        auto_save_enabled = true,
        auto_restore_enabled = true,
        auto_session_suppress_dirs = nil
    }

    require('auto-session').setup(opts)
end

return config