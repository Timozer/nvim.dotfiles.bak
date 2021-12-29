if 1 ~= vim.fn.has "nvim-0.5.1" then
  vim.api.nvim_err_writeln "This plugins requires neovim 0.5.1"
  vim.api.nvim_err_writeln "Please update your neovim."
  return
end

require('PLoop')
require('lib.gui.tools')
require('lib.gui.common')
require('lib.gui.gobject')
require('lib.gui.widget')
require('lib.gui.border')

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

    PLoop(function(_ENV)
        import "gui"

        local opts = {
            relative = GObject.Relative.Editor,
            geometry = { '0.5', '0.5', '0.8', '0.8' },
            bufopts = {
                buflisted = false,
                modifiable = false,
                readonly = true,
            },
            winopts = {
            },
            enter = true,
            border = Border.Style.Rounded,
        }
        win = Widget(opts, nil)
        win:Show()
    end)

end

return ctrlp
