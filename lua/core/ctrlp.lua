if 1 ~= vim.fn.has "nvim-0.5.1" then
  vim.api.nvim_err_writeln "This plugins requires neovim 0.5.1"
  vim.api.nvim_err_writeln "Please update your neovim."
  return
end

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

function ctrlp.load_command(start_line, end_line, count, cmd, ...)
    local args = { ... }
    for _, arg in ipairs(args) do
        print(arg)
    end

--     PLoop(function(_ENV)
--         import "gui"

--         local opts = {
--             relative = GObject.Relative.Editor,
--             geometry = { '0.5', '0.5', '0.8', '0.8' },
--             bufopts = {
--                 buflisted = false,
--                 modifiable = false,
--                 readonly = true,
--             },
--             winopts = {
--             },
--             enter = true,
--             border = Border.Style.Rounded,
--         }
--         win = Widget(opts, nil)
--         win:Show()
--     end)

end

return ctrlp
