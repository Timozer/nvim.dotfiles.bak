if 1 ~= vim.fn.has "nvim-0.5.1" then
  vim.api.nvim_err_writeln "This plugins requires neovim 0.5.1"
  vim.api.nvim_err_writeln "Please update your neovim."
  return
end

require('lib.gui.widget')
require('lib.gui.border')
require('lib.gui.gobject')

local ctrlp = {
    extensions = {}
}

-- Ref: https://github.com/tjdevries/lazy.nvim
function ctrlp.require_on_exported_call(mod)
  return setmetatable({}, {
    __index = function(_, picker)
      return function(...)
        return require(mod)[picker](...)
      end
    end,
  })
end

function ctrlp.register(mod)
    ctrlp.extensions[mod.name] = mod
end

function ctrlp.list_extensions()
    for mod, _ in pairs(ctrlp.extensions) do
        print('extension: '.. mod)
    end
end

-- local function run_command(args)
--   local user_opts = args or {}
--   if next(user_opts) == nil and not user_opts.cmd then
--     print "[Telescope] your command miss args"
--     return
--   end

--   local cmd = user_opts.cmd
--   local opts = user_opts.opts or {}
--   local extension_type = user_opts.extension_type or ""
--   local theme = user_opts.theme or ""

--   if next(opts) ~= nil then
--     command.convert_user_opts(opts)
--   end

--   if string.len(theme) > 0 then
--     local func = themes[theme] or themes["get_" .. theme]
--     opts = func(opts)
--   end

--   if string.len(extension_type) > 0 and extension_type ~= '"' then
--     extensions[cmd][extension_type](opts)
--     return
--   end

--   if builtin[cmd] then
--     builtin[cmd](opts)
--     return
--   end

--   if rawget(extensions, cmd) then
--     extensions[cmd][cmd](opts)
--   end
-- end

function ctrlp.load_command(start_line, end_line, count, cmd, ...)
    local args = { ... }
    for _, arg in ipairs(args) do
        print(arg)
    end

    local win = Widget.new({})
    win:Show()


--     local Popup = require("nui.popup")
--     local event = require("nui.utils.autocmd").event

--     local popup = Popup({
--         enter = true,
--         focusable = true,
--         border = {
--             style = "rounded",
--             highlight = "FloatBorder",
--         },
--         position = "50%",
--         size = {
--             width = "80%",
--             height = 1,
--         },
--         buf_options = {
--             modifiable = true,
--             readonly = false,
--         },
--     })

--     -- mount/open the component
--     popup:mount()

--     -- unmount component when cursor leaves buffer
--     popup:on(event.BufLeave, function() popup:unmount() end)

--     -- set content
--     vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, { "Hello World" })
--   if cmd == nil then
--     run_command { cmd = "builtin" }
--     return
--   end

--   local user_opts = {}
--   user_opts["cmd"] = cmd
--   user_opts.opts = {
--     start_line = start_line,
--     end_line = end_line,
--     count = count,
--   }

--   for _, arg in ipairs(args) do
--     if arg:find("=", 1) == nil then
--       user_opts["extension_type"] = arg
--     else
--       local param = vim.split(arg, "=")
--       local key = table.remove(param, 1)
--       param = table.concat(param, "=")
--       if key == "theme" then
--         user_opts["theme"] = param
--       else
--         user_opts.opts[key] = param
--       end
--     end
--   end

--   run_command(user_opts)
end

return ctrlp