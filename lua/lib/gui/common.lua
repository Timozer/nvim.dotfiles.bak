require('lib.functions')
require('lib.gui.tools')

PLoop(function(_ENV)
    namespace "gui"

    class "Common" (function(_ENV)
        __Static__()
        function GetEditorSize()
            return Size(vim.o.columns, vim.o.lines)
        end

        __Static__()
        function GetWindowSize(winid)
            if not winid or not vim.api.nvim_win_is_valid(winid) then
                return Size(-1, -1)
            end
            return Size(vim.api.nvim_win_get_width(winid), vim.api.nvim_win_get_height(winid))
        end

        __Static__()
        function SetBufOptions(buf, opts)
            if not buf or not vim.api.nvim_buf_is_valid(buf) then
                return
            end
            for key, val in pairs(opts) do
                vim.api.nvim_buf_set_option(buf, key, val)
            end
        end

        __Static__()
        function SetWinOptions(win, opts)
            if not win or not vim.api.nvim_win_is_valid(buf) then
                return
            end
            for key, val in pairs(opts) do
                vim.api.nvim_win_set_option(win, key, val)
            end
        end

        __Static__()
        function DestoryBuffer(bufnr, force)
            if not bufnr then
                return
            end

            -- Suppress the buffer deleted message for those with &report<2
            local start_report = vim.o.report
            if start_report < 2 then
                vim.o.report = 2
            end

            if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
                vim.api.nvim_buf_delete(bufnr, { force = force })
            end

            if start_report < 2 then
                vim.o.report = start_report
            end
        end

        __Static__()
        function DestoryWindow(winid, force)
            if not winid or not vim.api.nvim_win_is_valid(winid) then
                return
            end

            if not pcall(vim.api.nvim_win_close, winid, force) then
                log.trace("Unable to close window: ", name, "/", win_id)
            end
        end
    end)

end)

